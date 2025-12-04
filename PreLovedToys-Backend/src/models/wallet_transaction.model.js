const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const WalletTransaction = sequelize.define('WalletTransaction', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    walletId: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    type: {
        type: DataTypes.ENUM('credit', 'debit', 'transfer'),
        allowNull: false
    },
    amount: {
        type: DataTypes.BIGINT,
        allowNull: false
    },
    // Balance after this transaction (for quick history display)
    balanceAfter: {
        type: DataTypes.BIGINT,
        allowNull: true
    },
    // Optional reference to other user (for transfers)
    refUserId: {
        type: DataTypes.INTEGER,
        allowNull: true
    },
    // Human readable description
    description: {
        type: DataTypes.STRING,
        allowNull: true
    }
}, {
    tableName: 'tbl_wallet_transactions',
    timestamps: true
});

module.exports = WalletTransaction;
