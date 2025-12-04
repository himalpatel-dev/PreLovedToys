const express = require('express');
const router = express.Router();
const walletController = require('../controllers/wallet.controller');

// NOTE: Authentication middleware can be added where appropriate (e.g., req.user)
router.get('/:userId', walletController.getWallet);
router.post('/credit', walletController.credit);
router.post('/debit', walletController.debit);
router.post('/transfer', walletController.transfer);

module.exports = router;
