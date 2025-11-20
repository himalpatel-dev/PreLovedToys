const db = require('../models');
const CartItem = db.CartItem;
const Product = db.Product;
const ProductImage = db.ProductImage;

// 1. Add to Cart
const addToCart = async (userId, productId, quantity) => {
    try {
        // Check if item already exists in user's cart
        const existingItem = await CartItem.findOne({
            where: { userId, productId }
        });

        if (existingItem) {
            // If exists, update quantity
            existingItem.quantity += quantity;
            return await existingItem.save();
        } else {
            // If new, create it
            return await CartItem.create({
                userId,
                productId,
                quantity
            });
        }
    } catch (error) {
        throw error;
    }
};

// 2. Get User's Cart
const getCart = async (userId) => {
    try {
        const cart = await CartItem.findAll({
            where: { userId },
            include: [
                {
                    model: Product,
                    as: 'product',
                    include: [
                        {
                            model: ProductImage,
                            as: 'images',
                            where: { isPrimary: true }, // Only get the cover image
                            required: false // If no image exists, still return product
                        }
                    ]
                }
            ]
        });
        return cart;
    } catch (error) {
        throw error;
    }
};

// 3. Remove from Cart
const removeFromCart = async (userId, cartItemId) => {
    try {
        return await CartItem.destroy({
            where: { id: cartItemId, userId } // Ensure user owns the item
        });
    } catch (error) {
        throw error;
    }
};

module.exports = {
    addToCart,
    getCart,
    removeFromCart
};