const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const AgeGroup = sequelize.define('AgeGroup', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    name: {
        type: DataTypes.STRING, // e.g., "3-5 Years"
        allowNull: false,
        unique: true
    }
}, {
    tableName: 'tbl_Master_agegroups',
    timestamps: false
});

module.exports = AgeGroup;