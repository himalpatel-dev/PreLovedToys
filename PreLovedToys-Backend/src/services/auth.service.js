const db = require('../models');
const User = db.User;
const jwt = require('jsonwebtoken');
const walletService = require('./wallet.service');
const settingsService = require('./settings.service');
const AppError = require('../utils/app-error');

const BLOCKED_MESSAGE = 'This account has been blocked. Please contact support.';

// Helper: Generate 4 digit random number
const generateOtp = () => Math.floor(1000 + Math.random() * 9000).toString();

// 1. Send OTP (Login/Register)
const sendOtp = async (mobile) => {
    try {
        // const otp = generateOtp();
        const otp = 1111;
        const otpExpires = new Date(new Date().getTime() + 10 * 60000); // Expires in 10 mins

        // Find user or Create if not exists (Implicit Registration)
        const [user, created] = await User.findOrCreate({
            where: { mobile: mobile },
            defaults: { role: 'user' } // Default role for new users
        });

        // Banned accounts cannot sign in.
        if (!created && user.isActive === false) {
            throw new AppError(BLOCKED_MESSAGE, 403, 'ACCOUNT_BLOCKED');
        }

        // Update User with new OTP
        user.otp = otp;
        user.otpExpires = otpExpires;
        await user.save();

        // If user was just created, credit the welcome bonus (amount set by admins in Settings)
        if (created) {
            try {
                const bonus = await settingsService.get('welcomeBonus');
                if (bonus > 0) {
                    await walletService.credit(user.id, bonus, 'Welcome bonus for new registration');
                    console.log(`Credited ${bonus} coins to new user ${user.id}`);
                }
            } catch (err) {
                console.error('Failed to credit welcome bonus:', err.message || err);
                // Do not fail OTP sending if wallet credit fails
            }
        }

        // TODO: In a real production app, use an SMS API (Twilio/Fast2SMS) here.
        // For now, we return it so you can see it in the response/console.
        console.log(`>>> SIMULATED SMS TO ${mobile}: Your OTP is ${otp} <<<`);

        return { message: 'OTP sent successfully', otp: otp }; // We return OTP here just for testing!
    } catch (error) {
        throw error;
    }
};

// 2. Verify OTP
const verifyOtp = async (mobile, otp) => {
    try {
        const user = await User.findOne({ where: { mobile } });

        if (!user) {
            throw new Error('User not found');
        }

        if (user.isActive === false) {
            throw new AppError(BLOCKED_MESSAGE, 403, 'ACCOUNT_BLOCKED');
        }

        // Check if OTP matches
        if (user.otp !== otp) {
            throw new Error('Invalid OTP');
        }

        // Check if OTP is expired
        if (user.otpExpires < new Date()) {
            throw new Error('OTP has expired');
        }

        // Clear OTP after successful login
        user.otp = null;
        user.otpExpires = null;
        await user.save();

        // Generate JWT Token (This is the digital "ID card" for the app)
        const token = jwt.sign(
            { id: user.id, role: user.role },
            process.env.JWT_SECRET, // Put a strong secret in .env later
            { expiresIn: '30d' }
        );

        return {
            user: {
                id: user.id,
                mobile: user.mobile,
                name: user.name,
                role: user.role,
                isNewUser: !user.name // If name is null, it's a new user
            },
            token
        };
    } catch (error) {
        throw error;
    }
};

module.exports = {
    sendOtp,
    verifyOtp
};