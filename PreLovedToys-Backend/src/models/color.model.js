const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const Color = sequelize.define('Color', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    name: {
        type: DataTypes.STRING, // e.g., "Red"
        allowNull: false,
        unique: true
    },
    hexCode: {
        type: DataTypes.STRING, // e.g., "#FF0000" (Optional, good for UI)
        allowNull: true
    }
}, {
    tableName: 'tbl_Master_colors',
    timestamps: false
});

module.exports = Color;