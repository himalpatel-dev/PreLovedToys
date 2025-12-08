const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const SavedAddress = sequelize.define('SavedAddress', {
    id: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    receiver_name: {
        type: DataTypes.STRING,
        allowNull: false
    },
    phone_number: {
        type: DataTypes.STRING,
        allowNull: false
    },
    address_line1: {
        type: DataTypes.STRING,
        allowNull: false
    },
    address_line2: {
        type: DataTypes.STRING,
        allowNull: true
    },
    city: {
        type: DataTypes.STRING,
        allowNull: false
    },
    state: {
        type: DataTypes.STRING,
        allowNull: false
    },
    country: {
        type: DataTypes.STRING,
        allowNull: false
    },
    pincode: {
        type: DataTypes.STRING,
        allowNull: false
    },
    address_type: {
        type: DataTypes.ENUM('Home', 'Work', 'Other'),
        allowNull: false
    },
    is_default: {
        type: DataTypes.BOOLEAN,
        allowNull: false
    }
}, {
    tableName: 'tbl_saved_address',
    timestamps: true
});

module.exports = SavedAddress;
