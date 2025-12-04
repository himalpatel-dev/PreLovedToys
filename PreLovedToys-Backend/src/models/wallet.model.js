const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const Wallet = sequelize.define('Wallet', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    userId: {
        type: DataTypes.INTEGER,
        allowNull: false,
        unique: true
    },
    // Coins are stored as integer (smallest unit)
    balance: {
        type: DataTypes.BIGINT,
        allowNull: false,
        defaultValue: 0
    }
}, {
    tableName: 'tbl_wallets',
    timestamps: true
});

module.exports = Wallet;
