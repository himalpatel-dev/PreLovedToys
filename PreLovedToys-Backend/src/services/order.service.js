// services/order.service.js
const db = require('../models');
const { Order, OrderItem, CartItem, Product, ProductImage, User, sequelize } = db;

/**
 * Create an order for a user from their cart.
 * - Uses a transaction
 * - Moves cart items to order items
 * - Empties the cart
 */
const createOrder = async (userId, address) => {
    // Start a transaction
    const t = await db.sequelize.transaction();

    try {
        // A. Get all items from user's cart
        const cartItems = await CartItem.findAll({
            where: { userId },
            include: [{ model: Product, as: 'product' }]
        });

        if (cartItems.length === 0) {
            throw new Error("Cart is empty!");
        }

        // B. VALIDATION: Check if any product is ALREADY sold
        // This prevents 2 people buying the same unique item at the same time
        for (const item of cartItems) {
            if (item.product.status !== 'active') {
                throw new Error(`Sorry, "${item.product.title}" has just been sold to someone else!`);
            }
        }

        // C. Calculate Total Amount
        let totalAmount = 0;
        cartItems.forEach(item => {
            totalAmount += item.quantity * parseFloat(item.product.price);
        });

        // D. Create the Order
        const order = await Order.create({
            userId,
            totalAmount,
            shippingAddress: address,
            status: 'placed'
        }, { transaction: t });

        // E. Move Cart Items to Order Items
        const orderItemsData = cartItems.map(item => ({
            orderId: order.id,
            productId: item.productId,
            quantity: item.quantity,
            priceAtPurchase: item.product.price
        }));

        await OrderItem.bulkCreate(orderItemsData, { transaction: t });

        // F. *** CRITICAL UPDATE: MARK PRODUCTS AS SOLD ***
        // Collect all Product IDs
        const productIds = cartItems.map(item => item.productId);
        
        // Update their status to 'sold'
        await Product.update(
            { status: 'sold' },
            { 
                where: { id: productIds },
                transaction: t 
            }
        );

        // G. Empty the Cart
        await CartItem.destroy({
            where: { userId },
            transaction: t
        });

        // H. Commit (Save everything)
        await t.commit();
        
        return order;

    } catch (error) {
        // If anything fails, Rollback (Undo everything)
        await t.rollback();
        throw error;
    }
};

/**
 * Get orders for a specific user with items and one image per product
 */
const getUserOrders = async (userId) => {
    return Order.findAll({
        where: { userId },
        include: [
            {
                model: OrderItem,
                as: 'items',
                include: [
                    {
                        model: Product,
                        as: 'product',
                        include: [
                            {
                                model: ProductImage,
                                as: 'images',
                                attributes: ['imageUrl'],
                                limit: 1,
                            },
                        ],
                    },
                ],
            },
        ],
        order: [['createdAt', 'DESC']],
    });
};

/**
 * Admin: get all orders with user info and items
 */
const getAllOrdersAdmin = async () => {
    return Order.findAll({
        include: [
            {
                model: User,
                as: 'user',
                attributes: ['id', 'name', 'mobile', 'email'],
            },
            {
                model: OrderItem,
                as: 'items',
                include: [
                    {
                        model: Product,
                        as: 'product',
                        include: [
                            {
                                model: ProductImage,
                                as: 'images',
                                attributes: ['imageUrl'],
                                limit: 1,
                            },
                        ],
                    },
                ],
            },
        ],
        order: [['createdAt', 'DESC']],
    });
};

/**
 * Update status of an order
 * returns updated order or null if not found
 */
const updateOrderStatus = async (orderId, status) => {
    const order = await Order.findByPk(orderId);
    if (!order) return null;
    order.status = status;
    await order.save();
    return order;
};

module.exports = {
    createOrder,
    getUserOrders,
    getAllOrdersAdmin,
    updateOrderStatus,
};
