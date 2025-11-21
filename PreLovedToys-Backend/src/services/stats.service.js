const db = require('../models');
const User = db.User;
const Product = db.Product;
const Order = db.Order;
const { Op } = require('sequelize');

const getStats = async () => {
    try {
        // 1. Count Users (Exclude admins if needed, here we count 'user' role)
        const totalUsers = await User.count({
            where: { role: 'user' }
        });

        // 2. Count Active Products
        const activeProducts = await Product.count({
            where: { status: 'active' }
        });

        // 3. Count Total Orders
        const totalOrders = await Order.count();

        // 4. Calculate Total Revenue (Sum of totalAmount where order is not cancelled)
        const revenueData = await Order.sum('totalAmount', {
            where: {
                status: { [Op.ne]: 'cancelled' }
            }
        });

        // 5. Get Recent Orders (Limit 5)
        const recentOrders = await Order.findAll({
            limit: 5,
            order: [['createdAt', 'DESC']],
            include: [{ model: User, as: 'user', attributes: ['name'] }]
        });

        return {
            totalUsers,
            activeProducts,
            totalOrders,
            totalRevenue: revenueData || 0,
            recentOrders
        };
    } catch (error) {
        throw error;
    }
};

module.exports = {
    getStats
};