const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const ProductImage = sequelize.define('ProductImage', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    imageUrl: {
        type: DataTypes.STRING,
        allowNull: false
    },
    isPrimary: {
        type: DataTypes.BOOLEAN,
        defaultValue: false // True means this is the main cover photo
    }
    // productId will be added automatically by Sequelize relationships
}, {
    timestamps: false
});

module.exports = ProductImage;