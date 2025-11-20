const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const Material = sequelize.define('Material', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true, // We will use your specific IDs
        autoIncrement: true // Important: Since you provided specific IDs (1, 2, 4...)
    },
    name: {
        type: DataTypes.STRING, // e.g., "Plastic"
        allowNull: false
    }
}, {
    tableName: 'tbl_Master_materials',
    timestamps: false
});

module.exports = Material;