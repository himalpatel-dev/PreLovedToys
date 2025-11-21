const db = require('../models');
const User = db.User;

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

module.exports = {
    getAllUsers,
    toggleUserStatus
};