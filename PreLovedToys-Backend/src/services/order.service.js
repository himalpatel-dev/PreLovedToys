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
    const t = await sequelize.transaction();
    try {
        // A. Get cart items with product details
        const cartItems = await CartItem.findAll({
            where: { userId },
            include: [{ model: Product, as: 'product', required: true }],
            transaction: t,
            lock: t.LOCK.UPDATE, // optional: lock rows in transaction to avoid concurrency issues
        });

        if (!cartItems || cartItems.length === 0) {
            await t.rollback();
            throw new Error('Cart is empty!');
        }

        // B. Calculate total
        let totalAmount = 0;
        for (const item of cartItems) {
            const price = Number(item.product && item.product.price) || 0;
            totalAmount += item.quantity * price;
        }

        // C. Create order
        const order = await Order.create({
            userId,
            totalAmount,
            shippingAddress: address,
            status: 'placed',
        }, { transaction: t });

        // D. Create order items
        const orderItemsData = cartItems.map(item => ({
            orderId: order.id,
            productId: item.productId,
            quantity: item.quantity,
            priceAtPurchase: Number(item.product && item.product.price) || 0,
        }));

        await OrderItem.bulkCreate(orderItemsData, { transaction: t });

        // E. Empty cart
        await CartItem.destroy({ where: { userId }, transaction: t });

        await t.commit();
        return order;
    } catch (err) {
        try { await t.rollback(); } catch (rollbackErr) { console.error('rollback error', rollbackErr); }
        throw err;
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
