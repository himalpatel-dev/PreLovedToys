const db = require('../models');
const Order = db.Order;
const OrderItem = db.OrderItem;
const CartItem = db.CartItem;
const Product = db.Product;

// 1. Checkout (Place Order)
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

        // B. Calculate Total Amount
        let totalAmount = 0;
        cartItems.forEach(item => {
            totalAmount += item.quantity * parseFloat(item.product.price);
        });

        // C. Create the Order
        const order = await Order.create({
            userId,
            totalAmount,
            shippingAddress: address,
            status: 'placed'
        }, { transaction: t }); // Pass transaction object

        // D. Move Cart Items to Order Items
        const orderItemsData = cartItems.map(item => ({
            orderId: order.id,
            productId: item.productId,
            quantity: item.quantity,
            priceAtPurchase: item.product.price
        }));

        await OrderItem.bulkCreate(orderItemsData, { transaction: t });

        // E. Empty the Cart
        await CartItem.destroy({
            where: { userId },
            transaction: t
        });

        // F. Commit (Save everything)
        await t.commit();

        return order;

    } catch (error) {
        // If anything fails, Rollback (Undo everything)
        await t.rollback();
        throw error;
    }
};

// 2. Get User Orders
const getUserOrders = async (userId) => {
    try {
        return await Order.findAll({
            where: { userId },
            include: [
                {
                    model: OrderItem,
                    as: 'items',
                    include: [{ model: Product, as: 'product' }]
                }
            ],
            order: [['createdAt', 'DESC']]
        });
    } catch (error) {
        throw error;
    }
};

module.exports = {
    createOrder,
    getUserOrders
};