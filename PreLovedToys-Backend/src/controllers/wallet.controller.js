const walletService = require('../services/wallet.service');

async function getWallet(req, res) {
    try {
        const userId = req.user && req.user.id;
        if (!userId) return res.status(400).json({ message: 'User id required' });
        const result = await walletService.getHistory(userId, { limit: 100 });
        return res.json({ balance: result.wallet.balance, transactions: result.transactions });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: err.message });
    }
}

async function credit(req, res) {
    try {
        const { userId, amount, description } = req.body;
        if (!userId || !amount) return res.status(400).json({ message: 'userId and amount required' });
        const result = await walletService.credit(userId, amount, description);
        return res.json({ success: true, wallet: result.wallet, tx: result.tx });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: err.message });
    }
}

async function debit(req, res) {
    try {
        const { userId, amount, description } = req.body;
        if (!userId || !amount) return res.status(400).json({ message: 'userId and amount required' });
        const result = await walletService.debit(userId, amount, description);
        return res.json({ success: true, wallet: result.wallet, tx: result.tx });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: err.message });
    }
}

async function transfer(req, res) {
    try {
        const { fromUserId, toUserId, amount, description } = req.body;
        if (!fromUserId || !toUserId || !amount) return res.status(400).json({ message: 'fromUserId, toUserId and amount required' });
        const result = await walletService.transfer(fromUserId, toUserId, amount, description);
        return res.json({ success: true, ...result });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ message: err.message });
    }
}

module.exports = {
    getWallet,
    credit,
    debit,
    transfer
};
