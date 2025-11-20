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
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false
    },
    condition: {
        type: DataTypes.ENUM('New', 'Like New', 'Good', 'Fair'),
        allowNull: false
    },
    ageGroup: {
        type: DataTypes.STRING,
        allowNull: true
    },
    // REMOVED 'images' column from here
    status: {
        type: DataTypes.ENUM('pending', 'active', 'sold', 'rejected'),
        defaultValue: 'active'
    }
}, {
    timestamps: true
});

module.exports = Product;