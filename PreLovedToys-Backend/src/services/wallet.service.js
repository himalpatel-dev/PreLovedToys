const db = require('../models');

const sequelize = db.sequelize;

const Wallet = db.Wallet;
const WalletTransaction = db.WalletTransaction;

async function getOrCreateWallet(userId, tOptions = {}) {
    let wallet = await Wallet.findOne({ where: { userId } , transaction: tOptions.transaction});
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

async function credit(userId, amount, description = null, opts = {}) {
    if (amount <= 0) throw new Error('Amount must be positive');

    return await sequelize.transaction(async (t) => {
        const tOptions = { transaction: t };
        const wallet = await getOrCreateWallet(userId, tOptions);
        const newBalance = BigInt(wallet.balance) + BigInt(amount);
        await wallet.update({ balance: newBalance.toString() }, tOptions);
        const tx = await WalletTransaction.create({
            walletId: wallet.id,
            type: 'credit',
            amount,
            balanceAfter: newBalance.toString(),
            description
        }, tOptions);
        return { wallet, tx };
    });
}

async function debit(userId, amount, description = null, opts = {}) {
    if (amount <= 0) throw new Error('Amount must be positive');

    return await sequelize.transaction(async (t) => {
        const tOptions = { transaction: t };
        const wallet = await getOrCreateWallet(userId, tOptions);
        const curBalance = BigInt(wallet.balance);
        const amt = BigInt(amount);
        if (curBalance < amt) throw new Error('Insufficient balance');
        const newBalance = curBalance - amt;
        await wallet.update({ balance: newBalance.toString() }, tOptions);
        const tx = await WalletTransaction.create({
            walletId: wallet.id,
            type: 'debit',
            amount,
            balanceAfter: newBalance.toString(),
            description
        }, tOptions);
        return { wallet, tx };
    });
}

async function transfer(fromUserId, toUserId, amount, description = null) {
    if (fromUserId === toUserId) throw new Error('Cannot transfer to same user');
    if (amount <= 0) throw new Error('Amount must be positive');

    return await sequelize.transaction(async (t) => {
        const tOptions = { transaction: t };
        const fromWallet = await getOrCreateWallet(fromUserId, tOptions);
        const toWallet = await getOrCreateWallet(toUserId, tOptions);

        const fromBalance = BigInt(fromWallet.balance);
        const amt = BigInt(amount);
        if (fromBalance < amt) throw new Error('Insufficient balance');

        const newFrom = fromBalance - amt;
        const newTo = BigInt(toWallet.balance) + amt;

        await fromWallet.update({ balance: newFrom.toString() }, tOptions);
        await toWallet.update({ balance: newTo.toString() }, tOptions);

        const txFrom = await WalletTransaction.create({
            walletId: fromWallet.id,
            type: 'transfer',
            amount,
            balanceAfter: newFrom.toString(),
            refUserId: toUserId,
            description: description || `Transfer to user ${toUserId}`
        }, tOptions);

        const txTo = await WalletTransaction.create({
            walletId: toWallet.id,
            type: 'transfer',
            amount,
            balanceAfter: newTo.toString(),
            refUserId: fromUserId,
            description: description || `Transfer from user ${fromUserId}`
        }, tOptions);

        return { fromWallet, toWallet, txFrom, txTo };
    });
}

module.exports = {
    getOrCreateWallet,
    getBalance,
    getHistory,
    credit,
    debit,
    transfer
};
