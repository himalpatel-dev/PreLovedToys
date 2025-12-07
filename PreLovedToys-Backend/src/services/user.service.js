const db = require('../models');
const User = db.User;
const Order = db.Order;
const Product = db.Product;
const Wallet = db.Wallet;

// 1. Get User Profile by ID
const getUserProfile = async (userId) => {
    try {
        const user = await User.findByPk(userId, {
            attributes: { exclude: ['otp', 'otpExpires', 'password'] } // Exclude sensitive info
        });

        if (!user) {
            throw new Error('User not found');
        }

        return user;
    } catch (error) {
        throw error;
    }
};

// 2. Update User Profile
const updateUserProfile = async (userId, updateData) => {
    try {
        const user = await User.findByPk(userId);

        if (!user) {
            throw new Error('User not found');
        }

        // Allowed fields to update
        const allowedUpdates = [
            'name',
            'email',
            'gender',
            'occupation',
            'collegeOrUniversity',
            'aboutMe',
            'purpose',
            'interestedIn'
        ];

        // Only update allowed fields
        allowedUpdates.forEach((field) => {
            if (updateData[field] !== undefined) {
                user[field] = updateData[field];
            }
        });

        await user.save();

        // Return updated user without sensitive info
        const updatedUser = user.toJSON();
        delete updatedUser.otp;
        delete updatedUser.otpExpires;

        return updatedUser;
    } catch (error) {
        throw error;
    }
};

// 3. Get All Users (Admin)
const getAllUsers = async () => {
    try {
        const users = await User.findAll({
            attributes: { exclude: ['otp', 'otpExpires'] },
            order: [['createdAt', 'DESC']]
        });
        return users;
    } catch (error) {
        throw error;
    }
};

// 4. Get User Stats (Orders, Sales, Points)
const getUserStats = async (userId) => {
    try {
        // 1. Total Orders Placed (as Buyer)
        const totalOrders = await Order.count({
            where: { userId }
        });

        // 2. Total Products Sold (as Seller)
        const totalSales = await Product.count({
            where: {
                userId
            }
        });

        // 3. Wallet Balance
        const wallet = await Wallet.findOne({
            where: { userId }
        });
        const totalPoints = wallet ? wallet.balance : 0;

        return {
            totalOrders,
            totalSales,
            totalPoints
        };
    } catch (error) {
        throw error;
    }
};

module.exports = {
    getUserProfile,
    updateUserProfile,
    getAllUsers,
    getUserStats
};
