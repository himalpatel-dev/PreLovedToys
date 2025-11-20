const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth.controller');

// Route: POST /api/auth/send-otp
router.post('/send-otp', authController.sendOtp);

// Route: POST /api/auth/verify-otp
router.post('/verify-otp', authController.verifyOtp);

module.exports = router;