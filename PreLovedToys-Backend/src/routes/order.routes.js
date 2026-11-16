const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');
const verifyToken = require('../middlewares/auth.middleware');
const requireAdmin = require('../middlewares/admin.middleware');

router.use(verifyToken); // Protect all routes

// POST /api/orders (Checkout)
router.post('/', orderController.placeOrder);

// GET /api/orders (History)
router.get('/', orderController.getMyOrders);

// Admin only: changing a status can refund points and move them between users.
router.get('/admin/all', requireAdmin, orderController.getAllOrdersAdmin);
router.put('/admin/:id/status', requireAdmin, orderController.updateOrderStatus);

module.exports = router;
