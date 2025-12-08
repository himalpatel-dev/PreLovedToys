const express = require('express');
const router = express.Router();
const statsController = require('../controllers/stats.controller');
const verifyToken = require('../middlewares/auth.middleware');

router.use(verifyToken); // Protect all routes

// GET /api/stats
router.get('/', statsController.getDashboardStats);

module.exports = router;