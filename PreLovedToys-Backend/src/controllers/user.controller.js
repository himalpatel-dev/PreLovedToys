const db = require('../models');
const User = db.User;
const walletService = require('../services/wallet.service');
const userService = require('../services/user.service');

// 1. Get All Users (Exclude Admins usually, or show all)
const getAllUsers = async (req, res) => {
    try {
        const users = await User.findAll({
            where: { role: ['user', 'seller'] }, // Don't show other admins
            attributes: { exclude: ['password', 'otp', 'otpExpires'] }, // Security
            order: [['createdAt', 'DESC']]
        });
        res.status(200).json(users);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// 2. Toggle User Status (Ban/Unban)
const toggleUserStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { isActive } = req.body; // true or false

        const user = await User.findByPk(id);
        if (!user) return res.status(404).json({ message: "User not found" });

        user.isActive = isActive;
        await user.save();

        res.status(200).json({ message: `User ${isActive ? 'Activated' : 'Banned'} successfully` });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};



// 3. Update Profile (for authenticated user)
const updateProfile = async (req, res) => {
    try {
        const userId = req.user?.id;
        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const allowed = ['name', 'email', 'gender', 'occupation', 'collegeOrUniversity', 'aboutMe', 'purpose', 'interestedIn'];
        const updates = {};
        for (const key of allowed) {
            if (req.body[key] !== undefined) updates[key] = req.body[key];
        }

        const user = await User.findByPk(userId);
        if (!user) return res.status(404).json({ message: 'User not found' });

        // Determine points to credit based on fields that are being ADDED (empty -> filled)
        const pointsMap = {
            name: 20,
            email: 30,
            gender: 20,
            occupation: 20,
            collegeOrUniversity: 20,
            purpose: 30,
            aboutMe: 30,
            interestedIn: 30
        };

        let pointsToCredit = 0;
        const awarded = [];

        const isEmpty = (val) => {
            return val === null || val === undefined || (typeof val === 'string' && String(val).trim() === '') || (Array.isArray(val) && val.length === 0);
        };

        for (const key of Object.keys(pointsMap)) {
            if (updates[key] !== undefined) {
                const prev = user[key];
                const next = updates[key];
                // For interestedIn, frontend may send array while DB stores string; check semantics
                const prevEmpty = isEmpty(prev);
                const nextEmpty = isEmpty(next);
                if (prevEmpty && !nextEmpty) {
                    pointsToCredit += pointsMap[key];
                    awarded.push(key);
                }
            }
        }

        // Handle interestedIn type differences across DBs (convert array -> CSV for STRING column)
        if (updates.interestedIn !== undefined) {
            const attr = User.rawAttributes && User.rawAttributes.interestedIn;
            const attrType = attr && attr.type && attr.type.key ? attr.type.key : null;
            if (Array.isArray(updates.interestedIn) && attrType === 'STRING') {
                updates.interestedIn = updates.interestedIn.join(',');
            }
        }

        await user.update(updates);

        // If we have points to credit, credit the user's wallet and record a transaction
        let txResult = null;
        if (pointsToCredit > 0) {
            const desc = `Profile completion: awarded ${pointsToCredit} points for ${awarded.join(', ')}`;
            try {
                txResult = await walletService.credit(userId, pointsToCredit, desc);
            } catch (err) {
                // Log and continue — do not fail profile update because of wallet issue
                console.error('Failed to credit profile completion points:', err.message || err);
            }
        }

        // Return sanitized user (exclude OTP fields)
        const resp = user.toJSON();
        delete resp.otp;
        delete resp.otpExpires;

        const responsePayload = { message: 'Profile updated', user: resp };
        if (pointsToCredit > 0) {
            responsePayload.pointsCredited = pointsToCredit;
            responsePayload.awardedFields = awarded;
            responsePayload.transaction = txResult && txResult.tx ? { id: txResult.tx.id, balanceAfter: txResult.tx.balanceAfter } : null;
        }

        res.status(200).json(responsePayload);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};



// 3. Get Profile for authenticated user
const getProfile = async (req, res) => {
    try {
        const userId = req.user?.id;
        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const user = await User.findByPk(userId, { attributes: { exclude: ['otp', 'otpExpires'] } });
        if (!user) return res.status(404).json({ message: 'User not found' });

        res.status(200).json({ user });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};


// 4. Get User Stats
const getUserStats = async (req, res) => {
    try {
        const userId = req.user?.id;
        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const stats = await userService.getUserStats(userId);
        res.status(200).json(stats);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    getAllUsers,
    toggleUserStatus,
    updateProfile,
    getProfile,
    getUserStats
};