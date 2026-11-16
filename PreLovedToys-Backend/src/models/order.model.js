const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const Order = sequelize.define('Order', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    totalAmount: {
        type: DataTypes.BIGINT,
        allowNull: false
    },
    status: {
        type: DataTypes.ENUM('placed', 'packed', 'shipped', 'delivered', 'cancelled'),
        defaultValue: 'placed'
    },
    paymentStatus: {
        type: DataTypes.ENUM('pending', 'paid', 'failed'),
        defaultValue: 'pending'
    },
    shippingAddress: {
        type: DataTypes.TEXT, // We will store the full address string here for now
        allowNull: false
    },
    isPoints: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    // Separate totals so a cart with both points and rupee items is recorded correctly.
    // totalAmount is kept for older clients: the rupee total if there is one, else the points total.
    pointsTotal: {
        type: DataTypes.BIGINT,
        allowNull: false,
        defaultValue: 0
    },
    cashTotal: {
        type: DataTypes.BIGINT,
        allowNull: false,
        defaultValue: 0
    },
    cancelledAt: {
        type: DataTypes.DATE,
        allowNull: true
    },
    // userId will be added automatically
}, {
    tableName: 'tbl_orders',
    timestamps: true
});

module.exports = Order;