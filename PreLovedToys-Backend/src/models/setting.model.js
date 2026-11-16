const { DataTypes } = require('sequelize');
const sequelize = require('../config/db.config');

// Admin-editable app settings (points rules etc.), one row per key.
// Missing keys fall back to the defaults in services/settings.service.js.
const Setting = sequelize.define('Setting', {
    key: {
        type: DataTypes.STRING(64),
        primaryKey: true
    },
    value: {
        type: DataTypes.JSON,
        allowNull: false
    }
}, {
    tableName: 'tbl_settings',
    timestamps: true
});

module.exports = Setting;
