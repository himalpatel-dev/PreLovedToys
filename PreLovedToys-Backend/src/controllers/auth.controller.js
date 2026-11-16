const authService = require('../services/auth.service');

// Step 1: Send OTP
const sendOtp = async (req, res) => {
    try {
        const { mobile } = req.body;
        if (!mobile) return res.status(400).json({ message: "Mobile number is required" });

        const result = await authService.sendOtp(mobile);
        res.status(200).json(result);
    } catch (error) {
        res.status(error.status || 500).json({ message: error.message, code: error.code });
    }
};

// Step 2: Verify OTP
const verifyOtp = async (req, res) => {
    try {
        const { mobile, otp } = req.body;
        if (!mobile || !otp) return res.status(400).json({ message: "Mobile and OTP are required" });

        const result = await authService.verifyOtp(mobile, otp);
        res.status(200).json({
            message: "Login successful",
            ...result
        });
    } catch (error) {
        res.status(error.status || 401).json({ message: error.message, code: error.code });
    }
};

module.exports = {
    sendOtp,
    verifyOtp
};