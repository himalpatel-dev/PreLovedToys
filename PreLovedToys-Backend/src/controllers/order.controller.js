const orderService = require('../services/order.service');

const placeOrder = async (req, res) => {
    try {
        const userId = req.user.id;
        const { address } = req.body;

        if (!address) return res.status(400).json({ message: "Address is required" });

        const order = await orderService.createOrder(userId, address);
        res.status(201).json({ message: "Order placed successfully!", orderId: order.id });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getMyOrders = async (req, res) => {
    try {
        const userId = req.user.id;
        const orders = await orderService.getUserOrders(userId);
        res.status(200).json(orders);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { placeOrder, getMyOrders };