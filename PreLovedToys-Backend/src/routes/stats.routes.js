const express = require('express');
const router = express.Router();
const statsController = require('../controllers/stats.controller');
const verifyToken = require('../middlewares/auth.middleware');

// GET /api/stats
router.get('/', verifyToken, statsController.getDashboardStats);

module.exports = router;