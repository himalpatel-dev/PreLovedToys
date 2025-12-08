const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const Favorite = sequelize.define('Favorite', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    }
}, {
    tableName: 'tbl_favorites',
    timestamps: true
});

module.exports = Favorite;
