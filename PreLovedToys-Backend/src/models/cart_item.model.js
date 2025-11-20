const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const CartItem = sequelize.define('CartItem', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    quantity: {
        type: DataTypes.INTEGER,
        defaultValue: 1,
        allowNull: false
    }
    // userId and productId added automatically by relationships
}, {
    tableName: 'tbl_cart_items',
    timestamps: true
});

module.exports = CartItem;