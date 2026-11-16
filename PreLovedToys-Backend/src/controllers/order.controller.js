const orderService = require('../services/order.service');

/** Sends AppError status codes (400/409/...); anything else is a 500. */
const sendError = (res, err, label) => {
    const status = err.status || 500;
    if (status === 500) console.error(`${label} error:`, err);
    return res.status(status).json({ message: err.message || 'Internal server error', code: err.code });
};

const placeOrder = async (req, res) => {
    try {
        const userId = req.user && req.user.id;
        const { address } = req.body;

        if (!userId) return res.status(401).json({ message: 'Unauthorized' });
        if (!address) return res.status(400).json({ message: 'Address is required' });

        const order = await orderService.createOrder(userId, address);
        return res.status(201).json({
            message: 'Order placed successfully!',
            orderId: order.id,
            pointsTotal: order.pointsTotal,
            cashTotal: order.cashTotal
        });
    } catch (err) {
        return sendError(res, err, 'placeOrder');
    }
};

const getMyOrders = async (req, res) => {
    try {
        const userId = req.user && req.user.id;
        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const orders = await orderService.getUserOrders(userId);
        return res.status(200).json(orders);
    } catch (err) {
        return sendError(res, err, 'getMyOrders');
    }
};

// ADMIN: GET ALL ORDERS
const getAllOrdersAdmin = async (req, res) => {
    try {
        const orders = await orderService.getAllOrdersAdmin();
        return res.status(200).json(orders);
    } catch (err) {
        return sendError(res, err, 'getAllOrdersAdmin');
    }
};

// ADMIN: UPDATE ORDER STATUS (cancelling refunds points and puts listings back on sale)
const updateOrderStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body;

        if (!status) return res.status(400).json({ message: 'Status is required' });
        if (!orderService.ORDER_STATUSES.includes(status)) return res.status(400).json({ message: 'Invalid status value' });

        const result = await orderService.updateOrderStatus(id, status);
        if (!result) return res.status(404).json({ message: 'Order not found' });

        return res.status(200).json({ message: 'Order status updated', order: result.order, reversal: result.reversal });
    } catch (err) {
        return sendError(res, err, 'updateOrderStatus');
    }
};

module.exports = {
    placeOrder,
    getMyOrders,
    getAllOrdersAdmin,
    updateOrderStatus,
};
