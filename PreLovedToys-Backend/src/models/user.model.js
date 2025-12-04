const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

const User = sequelize.define('User', {
    id: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true
    },
    mobile: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true
    },
    name: {
        type: DataTypes.STRING,
        allowNull: true // Will be updated later in Profile
    },
    email: {
        type: DataTypes.STRING,
        allowNull: true // Will be updated later in Profile
    },
    // Profile fields
    gender: {
        type: DataTypes.STRING,
        allowNull: true
    },
    occupation: {
        type: DataTypes.STRING,
        allowNull: true
    },
    collegeOrUniversity: {
        type: DataTypes.STRING,
        allowNull: true
    },
    aboutMe: {
        type: DataTypes.TEXT,
        allowNull: true
    },
    purpose: {
        type: DataTypes.STRING,
        allowNull: true
    },
    // Store interested subcategory IDs as JSON array for flexibility
    interestedIn: {
        type: DataTypes.JSON,
        allowNull: true
    },
    role: {
        type: DataTypes.ENUM('admin', 'user', 'seller'),
        defaultValue: 'user'
    },
    // OTP Fields
    otp: {
        type: DataTypes.STRING,
        allowNull: true
    },
    otpExpires: {
        type: DataTypes.DATE,
        allowNull: true
    },
    isActive: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    }
}, {
    tableName: 'tbl_users',
    timestamps: true,
});

module.exports = User;