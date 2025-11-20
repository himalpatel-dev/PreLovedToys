const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');
require('dotenv').config(); // Ensure we can read .env

const ProductImage = sequelize.define('ProductImage', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    imageUrl: {
        type: DataTypes.STRING,
        allowNull: false,
        // <--- ADD THIS GETTER BLOCK
        get() {
            const rawValue = this.getDataValue('imageUrl');
            if (!rawValue) return null;

            // If the value is already a full URL (like the Categories we seeded), return it as is
            if (rawValue.startsWith('http')) {
                return rawValue;
            }

            // Otherwise, prepend the server domain and uploads folder
            return `${process.env.BASE_URL}/uploads/${rawValue}`;
        }
        // <--- END GETTER BLOCK
    },
    isPrimary: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    }
}, {
    tableName: 'tbl_product_images',
    timestamps: false
});

module.exports = ProductImage;