const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const SubCategory = sequelize.define('SubCategory', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    name: {
        type: DataTypes.STRING,
        allowNull: false
    },
    image: {
        type: DataTypes.STRING, // URL of the category icon/image
        allowNull: true
    },
    isActive: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    },
    // categoryId will be added automatically by relationships
}, {
    tableName: 'tbl_Master_subcategories',
    timestamps: false
});

module.exports = SubCategory;