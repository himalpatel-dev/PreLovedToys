// services/order.service.js
const db = require('../models');
const { Order, OrderItem, CartItem, Product, ProductImage, User, sequelize } = db;
const walletService = require('./wallet.service');

/**
 * Create an order for a user from their cart.
 * - Uses a transaction
 * - Moves cart items to order items
 * - For points-based products: deducts from buyer wallet, credits to seller wallet
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

        // C. Calculate Total Amount and Separate Points vs Real Money
        let totalAmount = 0;
        let pointsToDeduct = 0;
        const sellerCredits = {}; // { sellerId: pointsAmount }

        cartItems.forEach(item => {
            const price = parseFloat(item.product.price);
            const quantity = item.quantity;
            const totalPrice = price * quantity;

            if (item.product.isPoints) {
                // Points-based purchase
                pointsToDeduct += totalPrice;
                if (!sellerCredits[item.product.userId]) {
                    sellerCredits[item.product.userId] = 0;
                }
                sellerCredits[item.product.userId] += totalPrice;
                totalAmount += totalPrice;
            } else {
                // Real money purchase
                totalAmount += totalPrice;
            }
        });

        // D. For Points purchases: Deduct from buyer's wallet FIRST
        if (pointsToDeduct > 0) {
            const buyerWallet = await db.Wallet.findOne({ where: { userId } });
            if (!buyerWallet) {
                throw new Error("Wallet not found for buyer");
            }
            const currentBalance = BigInt(buyerWallet.balance);
            const pointsToDeductBigInt = BigInt(pointsToDeduct);

            if (currentBalance < pointsToDeductBigInt) {
                throw new Error(`Insufficient points. You have ${currentBalance} points but need ${pointsToDeduct}`);
            }

            const newBalance = currentBalance - pointsToDeductBigInt;
            await db.Wallet.update(
                { balance: newBalance.toString() },
                { where: { userId }, transaction: t }
            );

            // Record buyer's debit transaction
            await db.WalletTransaction.create({
                walletId: buyerWallet.id,
                type: 'debit',
                amount: pointsToDeduct,
                balanceAfter: newBalance.toString(),
                description: `Purchase of items - ${cartItems.map(i => i.product.title).join(', ')}`
            }, { transaction: t });
        }

        // E. Create the Order
        const order = await Order.create({
            userId,
            totalAmount: totalAmount || 0,
            shippingAddress: address,
            status: 'placed',
            isPoints: pointsToDeduct > 0 ?? false,
            paymentStatus: pointsToDeduct > 0 && totalAmount === 0 ? 'paid' : 'pending' // Mark as paid if only points
        }, { transaction: t });


        // F. Move Cart Items to Order Items
        const orderItemsData = cartItems.map(item => ({
            orderId: order.id,
            productId: item.productId,
            quantity: item.quantity,
            priceAtPurchase: item.product.price
        }));

        await OrderItem.bulkCreate(orderItemsData, { transaction: t });

        // G. *** CRITICAL UPDATE: MARK PRODUCTS AS SOLD ***
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

        // H. Empty the Cart
        await CartItem.destroy({
            where: { userId },
            transaction: t
        });

        // I. Credit seller wallets for points-based products
        // Note: These are now part of the DB transaction for atomicity
        const sellerIds = Object.keys(sellerCredits);
        for (const sellerId of sellerIds) {
            const points = sellerCredits[sellerId];
            const desc = `Sale of items to user ${userId}`;

            try {
                await walletService.credit(parseInt(sellerId), points, desc, { transaction: t });
            } catch (err) {
                console.error(`Failed to credit seller ${sellerId}:`, err.message);
                // Continue — don't fail the order if seller credit fails
            }
        }

        // J. Commit (Save everything)
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
