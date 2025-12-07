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
        type: DataTypes.BIGINT, // Important: We save the price AT THAT MOMENT
        allowNull: false
    }
    // orderId and productId added automatically
}, {
    tableName: 'tbl_order_items',
    timestamps: false
});

module.exports = OrderItem;