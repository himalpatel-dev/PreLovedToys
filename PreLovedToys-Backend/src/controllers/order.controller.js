const orderService = require('../services/order.service');

const placeOrder = async (req, res) => {
    try {
        const userId = req.user && req.user.id;
        const { address } = req.body;

        if (!userId) return res.status(401).json({ message: 'Unauthorized' });
        if (!address) return res.status(400).json({ message: 'Address is required' });

        const order = await orderService.createOrder(userId, address);
        return res.status(201).json({ message: 'Order placed successfully!', orderId: order.id });
    } catch (err) {
        console.error('placeOrder error:', err);
        return res.status(500).json({ message: err.message || 'Internal server error' });
    }
};

const getMyOrders = async (req, res) => {
    try {
        const userId = req.user && req.user.id;
        if (!userId) return res.status(401).json({ message: 'Unauthorized' });

        const orders = await orderService.getUserOrders(userId);
        return res.status(200).json(orders);
    } catch (err) {
        console.error('getMyOrders error:', err);
        return res.status(500).json({ message: err.message || 'Internal server error' });
    }
};

// ADMIN: GET ALL ORDERS
const getAllOrdersAdmin = async (req, res) => {
    try {
        // Optionally: check admin role here (e.g., req.user.role === 'admin')
        const orders = await orderService.getAllOrdersAdmin();
        return res.status(200).json(orders);
    } catch (err) {
        console.error('getAllOrdersAdmin error:', err);
        return res.status(500).json({ message: err.message || 'Internal server error' });
    }
};

// ADMIN: UPDATE ORDER STATUS
const updateOrderStatus = async (req, res) => {
    try {
        // Optionally: check admin role here
        const { id } = req.params;
        const { status } = req.body;

        if (!status) return res.status(400).json({ message: 'Status is required' });

        const allowed = ['placed', 'packed', 'shipped', 'delivered', 'cancelled'];
        if (!allowed.includes(status)) return res.status(400).json({ message: 'Invalid status value' });

        const updated = await orderService.updateOrderStatus(id, status);
        if (!updated) return res.status(404).json({ message: 'Order not found' });

        return res.status(200).json({ message: 'Order status updated', order: updated });
    } catch (err) {
        console.error('updateOrderStatus error:', err);
        return res.status(500).json({ message: err.message || 'Internal server error' });
    }
};

module.exports = {
    placeOrder,
    getMyOrders,
    getAllOrdersAdmin,
    updateOrderStatus,
};