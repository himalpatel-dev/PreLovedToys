const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const OrderItem = sequelize.define('OrderItem', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    quantity: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    priceAtPurchase: {
        type: DataTypes.DECIMAL(10, 2), // Important: We save the price AT THAT MOMENT
        allowNull: false
    }
    // orderId and productId added automatically
}, {
    timestamps: false
});

module.exports = OrderItem;