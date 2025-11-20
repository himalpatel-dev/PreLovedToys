const cartService = require('../services/cart.service');

const addToCart = async (req, res) => {
    try {
        const userId = req.user.id;
        const { productId, quantity } = req.body;

        if (!productId) return res.status(400).json({ message: "Product ID required" });

        await cartService.addToCart(userId, productId, quantity || 1);
        res.status(200).json({ message: "Item added to cart" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getCart = async (req, res) => {
    try {
        const userId = req.user.id;
        const cart = await cartService.getCart(userId);
        res.status(200).json(cart);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const remove = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params; // Cart Item ID from URL
        await cartService.removeFromCart(userId, id);
        res.status(200).json({ message: "Item removed" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = { addToCart, getCart, remove };