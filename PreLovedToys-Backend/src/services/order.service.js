// services/order.service.js
const db = require('../models');
const { Order, OrderItem, CartItem, Product, ProductImage, User, Wallet } = db;
const walletService = require('./wallet.service');
const AppError = require('../utils/app-error');

const ORDER_STATUSES = ['placed', 'packed', 'shipped', 'delivered', 'cancelled'];

/** Locks the given users' wallets in id order, so concurrent orders can't deadlock. */
async function lockWallets(userIds, transaction) {
    const ids = [...new Set(userIds.map(Number))].sort((a, b) => a - b);
    for (const userId of ids) {
        await Wallet.findOne({ where: { userId }, transaction, lock: transaction.LOCK.UPDATE });
    }
}

/**
 * Create an order for a user from their cart, in one transaction:
 * - locks the listings, so two buyers can't check out the same item at the same moment
 * - keeps points and rupee totals separate (a cart may contain both)
 * - takes the points from the buyer and pays each seller, with wallets locked
 * - marks the listings sold and empties the cart
 * If anything fails, nothing is saved.
 */
const createOrder = async (userId, address) => {
    return db.sequelize.transaction(async (transaction) => {
        const cartItems = await CartItem.findAll({ where: { userId }, transaction });
        if (cartItems.length === 0) throw new AppError('Cart is empty!');

        const productIds = [...new Set(cartItems.map((item) => item.productId))];
        const products = await Product.findAll({
            where: { id: productIds },
            order: [['id', 'ASC']],
            transaction,
            lock: transaction.LOCK.UPDATE,
        });
        const productById = new Map(products.map((p) => [p.id, p]));

        let pointsTotal = 0;
        let cashTotal = 0;
        const sellerCredits = new Map(); // sellerId -> points

        for (const item of cartItems) {
            const product = productById.get(item.productId);
            if (!product) throw new AppError('An item in your cart is no longer available. Please remove it and try again.', 409);
            if (product.status !== 'active') {
                throw new AppError(`Sorry, "${product.title}" has just been sold to someone else!`, 409);
            }
            if (product.userId === userId) {
                throw new AppError(`"${product.title}" is your own listing, so you can't buy it.`, 400);
            }
            const lineTotal = Number(product.price) * item.quantity;
            if (product.isPoints) {
                pointsTotal += lineTotal;
                sellerCredits.set(product.userId, (sellerCredits.get(product.userId) || 0) + lineTotal);
            } else {
                cashTotal += lineTotal;
            }
        }

        const order = await Order.create({
            userId,
            shippingAddress: address,
            status: 'placed',
            pointsTotal,
            cashTotal,
            // Single amount for older clients: rupees if any, otherwise points.
            totalAmount: cashTotal > 0 ? cashTotal : pointsTotal,
            isPoints: cashTotal === 0 && pointsTotal > 0,
            // Points are paid now; rupee payment is not handled yet.
            paymentStatus: cashTotal === 0 ? 'paid' : 'pending'
        }, { transaction });

        await OrderItem.bulkCreate(cartItems.map((item) => {
            const product = productById.get(item.productId);
            return {
                orderId: order.id,
                productId: product.id,
                quantity: item.quantity,
                priceAtPurchase: product.price,
                isPoints: !!product.isPoints,
                sellerId: product.userId
            };
        }), { transaction });

        if (pointsTotal > 0 || sellerCredits.size) {
            await lockWallets([userId, ...sellerCredits.keys()], transaction);
        }
        if (pointsTotal > 0) {
            // Fails with "Insufficient points" and rolls everything back if the buyer can't pay.
            await walletService.changeBalance(userId, -pointsTotal, {
                transaction, type: 'debit', description: `Purchase: order #${order.id}`
            });
        }
        for (const [sellerId, points] of sellerCredits) {
            await walletService.changeBalance(sellerId, points, {
                transaction, type: 'credit', refUserId: userId, description: `Sale: order #${order.id}`
            });
        }

        await Product.update({ status: 'sold' }, { where: { id: productIds }, transaction });
        await CartItem.destroy({ where: { userId }, transaction });

        return order;
    });
};

/**
 * Undoes an order's effects (called inside the cancel transaction):
 * refunds the buyer's points, takes the points back from each seller, and puts the
 * listings back on sale. A seller who already spent the points can go below zero.
 */
async function reverseOrder(order, transaction) {
    const items = await OrderItem.findAll({
        where: { orderId: order.id },
        include: [{ model: Product, as: 'product', attributes: ['id', 'userId', 'isPoints'] }],
        transaction
    });

    let refund = 0;
    const reversals = new Map(); // sellerId -> points
    for (const item of items) {
        // Saved at purchase; older orders fall back to the listing's current values.
        const isPoints = item.isPoints ?? item.product?.isPoints ?? false;
        const sellerId = item.sellerId ?? item.product?.userId ?? null;
        if (!isPoints) continue;
        const lineTotal = Number(item.priceAtPurchase) * item.quantity;
        refund += lineTotal;
        if (sellerId) reversals.set(sellerId, (reversals.get(sellerId) || 0) + lineTotal);
    }

    if (refund > 0) {
        await lockWallets([order.userId, ...reversals.keys()], transaction);
        await walletService.changeBalance(order.userId, refund, {
            transaction, type: 'credit', description: `Refund: order #${order.id} cancelled`
        });
        for (const [sellerId, points] of reversals) {
            await walletService.changeBalance(sellerId, -points, {
                transaction, type: 'debit', allowNegative: true, refUserId: order.userId,
                description: `Reversal: order #${order.id} cancelled`
            });
        }
    }

    const productIds = items.map((item) => item.productId).filter(Boolean);
    const [listingsRestored] = productIds.length
        ? await Product.update({ status: 'active' }, { where: { id: productIds, status: 'sold' }, transaction })
        : [0];

    return { pointsRefunded: refund, sellersCharged: reversals.size, listingsRestored };
}

/**
 * Changes an order's status. Cancelling refunds points and restores the listings (see
 * reverseOrder). A cancelled order is final. Returns { order, reversal } or null if not found.
 */
const updateOrderStatus = async (orderId, status) => {
    if (!ORDER_STATUSES.includes(status)) throw new AppError('Invalid status value');
    const id = Number(orderId);
    if (!Number.isInteger(id) || id < 1) return null;

    return db.sequelize.transaction(async (transaction) => {
        const order = await Order.findByPk(id, { transaction, lock: transaction.LOCK.UPDATE });
        if (!order) return null;
        if (order.status === status) return { order, reversal: null };
        if (order.status === 'cancelled') {
            throw new AppError('This order is cancelled and can no longer be changed.', 409);
        }

        let reversal = null;
        if (status === 'cancelled') {
            reversal = await reverseOrder(order, transaction);
            order.cancelledAt = new Date();
        }
        order.status = status;
        await order.save({ transaction });
        return { order, reversal };
    });
};

/** Items with their listing and photos (cover first). */
const itemsInclude = () => ({
    model: OrderItem,
    as: 'items',
    separate: true,
    include: [{
        model: Product,
        as: 'product',
        include: [{
            model: ProductImage,
            as: 'images',
            attributes: ['id', 'imageUrl', 'isPrimary', 'sortOrder'],
            separate: true,
            order: [['sortOrder', 'ASC'], ['id', 'ASC']],
        }],
    }],
});

/**
 * Get orders for a specific user with items and their photos
 */
const getUserOrders = async (userId) => {
    return Order.findAll({
        where: { userId },
        include: [itemsInclude()],
        order: [['createdAt', 'DESC']],
    });
};

/**
 * Admin: get all orders with user info and items
 */
const getAllOrdersAdmin = async () => {
    return Order.findAll({
        include: [
            { model: User, as: 'user', attributes: ['id', 'name', 'mobile', 'email'] },
            itemsInclude(),
        ],
        order: [['createdAt', 'DESC']],
    });
};

module.exports = {
    ORDER_STATUSES,
    createOrder,
    getUserOrders,
    getAllOrdersAdmin,
    updateOrderStatus,
};
