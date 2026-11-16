const db = require('../models');
const AppError = require('../utils/app-error');

const sequelize = db.sequelize;

const Wallet = db.Wallet;
const WalletTransaction = db.WalletTransaction;

async function getOrCreateWallet(userId, tOptions = {}) {
    let wallet = await Wallet.findOne({ where: { userId }, transaction: tOptions.transaction });
    if (!wallet) {
        wallet = await Wallet.create({ userId, balance: 0 }, tOptions);
    }
    return wallet;
}

async function getBalance(userId) {
    const wallet = await getOrCreateWallet(userId);
    return wallet.balance;
}

async function getHistory(userId, { limit = 50, offset = 0 } = {}) {
    const wallet = await getOrCreateWallet(userId);
    const transactions = await WalletTransaction.findAll({
        where: { walletId: wallet.id },
        order: [['createdAt', 'DESC']],
        limit,
        offset
    });
    return { wallet, transactions };
}

/**
 * The one place balances change. Adds `delta` points (negative removes them) and records
 * a transaction row.
 *
 * The wallet row is locked (SELECT ... FOR UPDATE) for the rest of the transaction, so two
 * changes to the same wallet at the same moment run one after the other instead of both
 * reading the old balance. Pass options.transaction to join an existing transaction.
 *
 * options: { transaction, type, description, refUserId, allowNegative }
 * allowNegative lets a reversal (e.g. taking back a seller's points after a cancelled
 * order) go below zero instead of failing.
 */
async function changeBalance(userId, delta, options = {}) {
    const amount = Number(delta);
    if (!Number.isInteger(amount) || amount === 0) throw new AppError('Points amount must be a whole number other than 0.');

    const run = async (transaction) => {
        let wallet = await Wallet.findOne({ where: { userId }, transaction, lock: transaction.LOCK.UPDATE });
        if (!wallet) wallet = await Wallet.create({ userId, balance: 0 }, { transaction });

        const current = BigInt(wallet.balance);
        const next = current + BigInt(amount);
        if (next < 0n && !options.allowNegative) {
            throw new AppError(`Insufficient points. You have ${current} points but need ${-amount}.`, 400, 'INSUFFICIENT_POINTS');
        }

        await wallet.update({ balance: next.toString() }, { transaction });
        const tx = await WalletTransaction.create({
            walletId: wallet.id,
            type: options.type || (amount > 0 ? 'credit' : 'debit'),
            amount: Math.abs(amount),
            balanceAfter: next.toString(),
            refUserId: options.refUserId || null,
            description: options.description ? String(options.description).slice(0, 255) : null
        }, { transaction });

        return { wallet, tx, balance: next.toString() };
    };

    return options.transaction ? run(options.transaction) : sequelize.transaction(run);
}

async function credit(userId, amount, description = null, opts = {}) {
    if (amount <= 0) throw new AppError('Amount must be positive');
    return changeBalance(userId, amount, { transaction: opts.transaction, type: 'credit', description });
}

async function debit(userId, amount, description = null, opts = {}) {
    if (amount <= 0) throw new AppError('Amount must be positive');
    return changeBalance(userId, -amount, { transaction: opts.transaction, type: 'debit', description });
}

async function transfer(fromUserIdRaw, toUserIdRaw, amount, description = null) {
    const fromUserId = Number(fromUserIdRaw);
    const toUserId = Number(toUserIdRaw);
    if (fromUserId === toUserId) throw new AppError('Cannot transfer to same user');
    if (amount <= 0) throw new AppError('Amount must be positive');

    return await sequelize.transaction(async (transaction) => {
        // Lock both wallets in a fixed order (lower user id first) so two opposite
        // transfers can't deadlock each other.
        const first = Math.min(fromUserId, toUserId);
        const steps = {
            [fromUserId]: () => changeBalance(fromUserId, -amount, {
                transaction, type: 'transfer', refUserId: toUserId,
                description: description || `Transfer to user ${toUserId}`
            }),
            [toUserId]: () => changeBalance(toUserId, amount, {
                transaction, type: 'transfer', refUserId: fromUserId,
                description: description || `Transfer from user ${fromUserId}`
            })
        };
        const a = await steps[first]();
        const b = await steps[first === fromUserId ? toUserId : fromUserId]();
        const [from, to] = first === fromUserId ? [a, b] : [b, a];
        return { fromWallet: from.wallet, toWallet: to.wallet, txFrom: from.tx, txTo: to.tx };
    });
}

module.exports = {
    getOrCreateWallet,
    getBalance,
    getHistory,
    changeBalance,
    credit,
    debit,
    transfer
};
