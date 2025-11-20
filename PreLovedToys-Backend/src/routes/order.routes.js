const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const verifyToken = require('../middlewares/auth.middleware');

router.use(verifyToken); // Protect all routes

// POST /api/orders (Checkout)
router.post('/', orderController.placeOrder);

// GET /api/orders (History)
router.get('/', orderController.getMyOrders);

module.exports = router;