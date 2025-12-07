const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const Product = sequelize.define('Product', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    title: {
        type: DataTypes.STRING,
        allowNull: false
    },
    description: {
        type: DataTypes.TEXT,
        allowNull: false
    },
    price: {
        type: DataTypes.BIGINT,
        allowNull: false
    },
    isPoints: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,  // true = points/coins, false = real money
        comment: 'If true, price is in points/coins. If false, price is in real money (₹).'
    },
    condition: {
        type: DataTypes.ENUM('New', 'Like New', 'Good', 'Fair'),
        allowNull: false
    },
    status: {
        type: DataTypes.ENUM('pending', 'active', 'sold', 'rejected'),
        defaultValue: 'active'
    }
}, {
    tableName: 'tbl_products',
    timestamps: true
});

module.exports = Product;