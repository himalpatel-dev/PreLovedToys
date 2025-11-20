const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const Gender = sequelize.define('Gender', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    name: {
        type: DataTypes.STRING, // e.g., "Boys"
        allowNull: false
    }
}, {
    tableName: 'tbl_Master_genders',
    timestamps: false
});

module.exports = Gender;