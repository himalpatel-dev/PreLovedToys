/**
 * Admin-only queries and actions used by the admin portal (routes/admin.routes.js).
 * List endpoints are paged and return { items, total, page, limit, counts }.
 */
const { Op, QueryTypes } = require('sequelize');
const db = require('../models');
const AppError = require('../utils/app-error');
const productService = require('./product.service');
const orderService = require('./order.service');
const walletService = require('./wallet.service');
const settingsService = require('./settings.service');

const {
    Product, ProductImage, Category, SubCategory, User,
    Order, OrderItem, Wallet, WalletTransaction, CartItem, Favorite,
} = db;

/** Kept as a name for existing callers; same as AppError. */
const AdminError = AppError;

const PRODUCT_STATUSES = ['pending', 'active', 'sold', 'rejected'];
const ORDER_STATUSES = ['placed', 'packed', 'shipped', 'delivered', 'cancelled'];
const CUSTOMER_ROLES = ['user', 'seller'];
const MAX_ADJUSTMENT = 1000000;

// SQL for an order's rupee and points amounts. Orders placed before pointsTotal/cashTotal
// existed have both at 0, so they fall back to totalAmount + isPoints.
const SQL_CASH = `CASE WHEN "pointsTotal" > 0 OR "cashTotal" > 0 THEN "cashTotal" WHEN NOT "isPoints" THEN "totalAmount" ELSE 0 END`;
const SQL_POINTS = `CASE WHEN "pointsTotal" > 0 OR "cashTotal" > 0 THEN "pointsTotal" WHEN "isPoints" THEN "totalAmount" ELSE 0 END`;

// ---------- helpers ----------

function paging(query) {
    const page = Math.max(1, parseInt(query.page, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(query.limit, 10) || 20));
    return { page, limit, offset: (page - 1) * limit };
}

function searchTerm(query) {
    return typeof query.search === 'string' ? query.search.trim().slice(0, 100) : '';
}

/** Case-insensitive "contains" match with LIKE wildcards escaped. */
function contains(text) {
    return { [Op.iLike]: `%${text.replace(/[\\%_]/g, '\\$&')}%` };
}

/** A search that is a plain number (optionally "#123") and fits an INTEGER id. */
function idFromSearch(text) {
    const digits = text.replace(/^#/, '');
    return /^\d{1,9}$/.test(digits) ? Number(digits) : null;
}

function parseId(value, label = 'id') {
    const id = Number(value);
    if (!Number.isInteger(id) || id < 1) throw new AppError(`Invalid ${label}.`);
    return id;
}

function optionalId(value, label) {
    return value === undefined || value === '' ? null : parseId(value, label);
}

async function userIdsMatching(text) {
    const users = await User.findAll({
        attributes: ['id'],
        where: { [Op.or]: [{ name: contains(text) }, { mobile: contains(text) }] },
    });
    return users.map((u) => u.id);
}

/** { all, <status>: n, ... } for the rows matching `where`. */
async function countBy(Model, where, column) {
    const rows = await Model.count({ where, group: [column] });
    const counts = { all: 0 };
    for (const row of rows) {
        const n = Number(row.count);
        counts[String(row[column])] = n;
        counts.all += n;
    }
    return counts;
}

/** Ids of orders that contain at least one item sold by `sellerId`. */
async function sellerOrderIds(sellerId) {
    const productIds = (await Product.findAll({ attributes: ['id'], where: { userId: sellerId } })).map((p) => p.id);
    const or = [{ sellerId }];
    if (productIds.length) or.push({ sellerId: null, productId: productIds }); // orders placed before sellerId was saved
    const rows = await OrderItem.findAll({ attributes: ['orderId'], where: { [Op.or]: or }, raw: true });
    return [...new Set(rows.map((r) => r.orderId))];
}

// ---------- products ----------

async function listProducts(query) {
    const { page, limit, offset } = paging(query);
    const search = searchTerm(query);

    const where = {};
    const sellerId = optionalId(query.sellerId, 'seller id');
    if (sellerId) where.userId = sellerId;
    if (search) {
        const [sellerIds, categories] = await Promise.all([
            userIdsMatching(search),
            Category.findAll({ attributes: ['id'], where: { name: contains(search) } }),
        ]);
        const or = [{ title: contains(search) }];
        const id = idFromSearch(search);
        if (id) or.push({ id });
        if (sellerIds.length) or.push({ userId: sellerIds });
        if (categories.length) or.push({ categoryId: categories.map((c) => c.id) });
        where[Op.or] = or;
    }

    const counts = await countBy(Product, where, 'status');
    const status = PRODUCT_STATUSES.includes(query.status) ? query.status : null;

    const { rows, count } = await Product.findAndCountAll({
        where: status ? { ...where, status } : where,
        include: [
            {
                model: ProductImage, as: 'images', attributes: ['id', 'imageUrl', 'isPrimary', 'sortOrder'],
                separate: true, order: [['sortOrder', 'ASC'], ['id', 'ASC']],
            },
            { model: Category, as: 'category', attributes: ['id', 'name'] },
            { model: SubCategory, as: 'subcategory', attributes: ['id', 'name'] },
            { model: User, as: 'seller', attributes: ['id', 'name', 'mobile'] },
        ],
        order: [['createdAt', 'DESC'], ['id', 'DESC']],
        limit,
        offset,
        distinct: true,
    });

    return { items: rows, total: count, page, limit, counts };
}

/** Updates the editable details of a listing. Only fields present in `body` change. */
async function updateProduct(productId, body = {}) {
    const id = parseId(productId, 'product id');
    const product = await Product.findByPk(id);
    if (!product) throw new AppError('Product not found.', 404);

    const changes = await productService.buildDetailChanges(product, body);
    if (!Object.keys(changes).length) throw new AppError('Nothing to update.');
    await product.update(changes);
    return productService.getProductById(id);
}

/**
 * Deletes a listing with its photos, cart entries and favourites. Listings that appear in
 * any order are kept for the order history; reject them instead.
 */
async function deleteProduct(productId) {
    const id = parseId(productId, 'product id');
    return db.sequelize.transaction(async (transaction) => {
        const product = await Product.findByPk(id, { transaction, lock: transaction.LOCK.UPDATE });
        if (!product) throw new AppError('Product not found.', 404);

        const inOrders = await OrderItem.count({ where: { productId: id }, transaction });
        if (inOrders) {
            throw new AppError(
                `“${product.title}” is part of ${inOrders} order${inOrders === 1 ? '' : 's'}, so it can't be deleted ` +
                '(the order history needs it). Reject it instead to hide it from buyers.', 409
            );
        }

        await CartItem.destroy({ where: { productId: id }, transaction });
        await Favorite.destroy({ where: { productId: id }, transaction });
        await ProductImage.destroy({ where: { productId: id }, transaction });
        await product.destroy({ transaction });
        return { deleted: true, id, title: product.title };
    });
}

const addProductImage = (productId, body = {}) => productService.addImage(productId, body.imageUrl);
const removeProductImage = (productId, imageId) => productService.removeImage(productId, imageId);
const reorderProductImages = (productId, body = {}) => productService.reorderImages(productId, body.imageIds);

// ---------- orders ----------

async function listOrders(query) {
    const { page, limit, offset } = paging(query);
    const search = searchTerm(query);

    const where = {};
    const buyerId = optionalId(query.userId, 'user id');
    if (buyerId) where.userId = buyerId;
    const sellerId = optionalId(query.sellerId, 'seller id');
    if (sellerId) where.id = await sellerOrderIds(sellerId);
    if (search) {
        const or = [];
        const id = idFromSearch(search);
        if (id) or.push({ id });
        const userIds = await userIdsMatching(search);
        if (userIds.length) or.push({ userId: userIds });
        where[Op.or] = or.length ? or : [{ id: -1 }];
    }

    const counts = await countBy(Order, where, 'status');
    const status = ORDER_STATUSES.includes(query.status) ? query.status : null;

    const { rows, count } = await Order.findAndCountAll({
        where: status ? { ...where, status } : where,
        include: [
            { model: User, as: 'user', attributes: ['id', 'name', 'mobile', 'email'] },
            {
                model: OrderItem, as: 'items', separate: true,
                include: [{
                    model: Product, as: 'product', attributes: ['id', 'title', 'price', 'isPoints'],
                    include: [{
                        model: ProductImage, as: 'images', attributes: ['imageUrl', 'isPrimary', 'sortOrder'],
                        separate: true, order: [['sortOrder', 'ASC'], ['id', 'ASC']],
                    }],
                }],
            },
        ],
        order: [['createdAt', 'DESC'], ['id', 'DESC']],
        limit,
        offset,
        distinct: true,
    });

    return { items: rows, total: count, page, limit, counts };
}

async function setOrderStatus(orderId, body = {}) {
    if (!ORDER_STATUSES.includes(body.status)) throw new AppError(`Status must be one of: ${ORDER_STATUSES.join(', ')}.`);
    const result = await orderService.updateOrderStatus(orderId, body.status);
    if (!result) throw new AppError('Order not found.', 404);
    return result;
}

// ---------- users ----------

async function listUsers(query) {
    const { page, limit, offset } = paging(query);
    const search = searchTerm(query);

    const where = { role: CUSTOMER_ROLES };
    if (search) {
        where[Op.or] = [{ name: contains(search) }, { mobile: contains(search) }, { email: contains(search) }];
    }

    const byActive = await countBy(User, where, 'isActive');
    const counts = { all: byActive.all, active: byActive.true || 0, banned: byActive.false || 0 };

    const filter = query.status === 'active' ? { isActive: true } : query.status === 'banned' ? { isActive: false } : {};
    const { rows, count } = await User.findAndCountAll({
        where: { ...where, ...filter },
        attributes: ['id', 'mobile', 'name', 'email', 'role', 'isActive', 'createdAt'],
        include: [{ model: Wallet, as: 'wallet', attributes: ['balance'] }],
        order: [['createdAt', 'DESC'], ['id', 'DESC']],
        limit,
        offset,
    });

    const items = rows.map((u) => {
        const { wallet, ...user } = u.toJSON();
        return { ...user, balance: wallet ? wallet.balance : '0' };
    });
    return { items, total: count, page, limit, counts };
}

/** One user's profile plus totals for their listings, purchases, sales and points. */
async function getUserDetail(userIdParam) {
    const id = parseId(userIdParam, 'user id');
    const user = await User.findByPk(id, { attributes: { exclude: ['otp', 'otpExpires'] } });
    if (!user) throw new AppError('User not found.', 404);

    const [wallet, listings, [purchases], saleOrderIds] = await Promise.all([
        Wallet.findOne({ where: { userId: id }, attributes: ['balance'] }),
        countBy(Product, { userId: id }, 'status'),
        db.sequelize.query(
            `SELECT
               COUNT(*) FILTER (WHERE status <> 'cancelled') AS orders,
               COUNT(*) FILTER (WHERE status = 'cancelled') AS cancelled,
               COALESCE(SUM(${SQL_POINTS}) FILTER (WHERE status <> 'cancelled'), 0) AS points,
               COALESCE(SUM(${SQL_CASH}) FILTER (WHERE status <> 'cancelled'), 0) AS cash
             FROM tbl_orders WHERE "userId" = :id`,
            { replacements: { id }, type: QueryTypes.SELECT }
        ),
        sellerOrderIds(id),
    ]);

    return {
        user,
        balance: wallet ? wallet.balance : '0',
        listings,
        purchases: {
            orders: Number(purchases.orders),
            cancelled: Number(purchases.cancelled),
            pointsSpent: String(purchases.points),
            cashSpent: String(purchases.cash),
        },
        sales: { orders: saleOrderIds.length },
    };
}

// ---------- wallets / points ----------

async function listWallets(query) {
    const { page, limit, offset } = paging(query);
    const search = searchTerm(query);

    const where = { role: CUSTOMER_ROLES };
    if (search) where[Op.or] = [{ name: contains(search) }, { mobile: contains(search) }];

    const [{ rows, count }, totalPoints, holders] = await Promise.all([
        User.findAndCountAll({
            where,
            attributes: ['id', 'mobile', 'name', 'isActive'],
            include: [{ model: Wallet, as: 'wallet', attributes: ['balance', 'updatedAt'] }],
            order: [[{ model: Wallet, as: 'wallet' }, 'balance', 'DESC NULLS LAST'], ['id', 'ASC']],
            limit,
            offset,
        }),
        Wallet.sum('balance'),
        Wallet.count({ where: { balance: { [Op.gt]: 0 } } }),
    ]);

    const items = rows.map((u) => {
        const { wallet, ...user } = u.toJSON();
        return { ...user, balance: wallet ? wallet.balance : '0', lastActivity: wallet ? wallet.updatedAt : null };
    });
    return {
        items, total: count, page, limit,
        summary: { totalPoints: String(totalPoints || 0), holders },
    };
}

async function getWallet(userIdParam, query) {
    const userId = parseId(userIdParam, 'user id');
    const { page, limit, offset } = paging(query);

    const user = await User.findByPk(userId, {
        attributes: ['id', 'mobile', 'name', 'email', 'role', 'isActive', 'createdAt'],
    });
    if (!user) throw new AppError('User not found.', 404);

    // Reading must not create a wallet, so a user without one simply has 0 points.
    const wallet = await Wallet.findOne({ where: { userId } });
    if (!wallet) return { user, balance: '0', items: [], total: 0, page, limit };

    const { rows, count } = await WalletTransaction.findAndCountAll({
        where: { walletId: wallet.id },
        order: [['createdAt', 'DESC'], ['id', 'DESC']],
        limit,
        offset,
    });

    const refIds = [...new Set(rows.map((r) => r.refUserId).filter(Boolean))];
    const refUsers = refIds.length
        ? await User.findAll({ where: { id: refIds }, attributes: ['id', 'name', 'mobile'] })
        : [];
    const items = rows.map((r) => ({
        ...r.toJSON(),
        refUser: refUsers.find((u) => u.id === r.refUserId) || null,
    }));

    return { user, balance: wallet.balance, items, total: count, page, limit };
}

/**
 * Adds (amount > 0) or removes (amount < 0) points, recording who did it and why.
 * Pass opts.transaction to run inside an existing transaction.
 */
async function adjustWallet(userIdParam, body = {}, admin, opts = {}) {
    const userId = parseId(userIdParam, 'user id');
    const amount = Number(body.amount);
    if (!Number.isInteger(amount) || amount === 0) throw new AppError('Amount must be a whole number other than 0.');
    if (Math.abs(amount) > MAX_ADJUSTMENT) {
        throw new AppError(`At most ${MAX_ADJUSTMENT.toLocaleString('en-IN')} points can be adjusted at once.`);
    }
    const reason = typeof body.reason === 'string' ? body.reason.trim() : '';
    if (reason.length < 3) throw new AppError('Please give a reason (at least 3 characters).');

    const user = await User.findByPk(userId, { attributes: ['id'] });
    if (!user) throw new AppError('User not found.', 404);

    const by = admin ? ` (by admin #${admin.id})` : '';
    const description = `Admin adjustment: ${reason}`.slice(0, 255 - by.length) + by;

    try {
        const result = await walletService.changeBalance(userId, amount, {
            transaction: opts.transaction,
            type: amount > 0 ? 'credit' : 'debit',
            description,
        });
        return { balance: result.balance, transaction: result.tx };
    } catch (err) {
        if (err.code === 'INSUFFICIENT_POINTS') {
            const wallet = await Wallet.findOne({ where: { userId }, attributes: ['balance'] });
            throw new AppError(`Cannot remove ${-amount} points: the balance is only ${wallet ? wallet.balance : 0}.`);
        }
        throw err;
    }
}

// ---------- catalogue (categories incl. hidden ones) ----------

/** Every category (hidden ones too) with its sub-categories and how many listings use each. */
async function listCategories() {
    const [categories, byCategory, bySub] = await Promise.all([
        Category.findAll({
            include: [{ model: SubCategory, as: 'subcategories' }],
            order: [['name', 'ASC'], [{ model: SubCategory, as: 'subcategories' }, 'name', 'ASC']],
        }),
        Product.count({ group: ['categoryId'] }),
        Product.count({ group: ['subCategoryId'] }),
    ]);
    const catCount = new Map(byCategory.map((r) => [r.categoryId, Number(r.count)]));
    const subCount = new Map(bySub.map((r) => [r.subCategoryId, Number(r.count)]));

    return categories.map((c) => {
        const json = c.toJSON();
        return {
            ...json,
            productCount: catCount.get(c.id) || 0,
            subcategories: json.subcategories.map((s) => ({ ...s, productCount: subCount.get(s.id) || 0 })),
        };
    });
}

async function setVisibility(Model, idParam, body = {}, label) {
    const id = parseId(idParam, `${label} id`);
    if (typeof body.isActive !== 'boolean') throw new AppError('isActive must be true or false.');
    const row = await Model.findByPk(id);
    if (!row) throw new AppError(`${label} not found.`, 404);
    await row.update({ isActive: body.isActive });
    return row;
}

const setCategoryVisibility = (id, body) => setVisibility(Category, id, body, 'Category');
const setSubCategoryVisibility = (id, body) => setVisibility(SubCategory, id, body, 'Sub-category');

// ---------- settings ----------

const getSettings = () => settingsService.getAll();
const updateSettings = (body) => settingsService.update(body);

// ---------- dashboard ----------

const RANGES = {
    '7d': { unit: 'day', count: 7 },
    '30d': { unit: 'day', count: 30 },
    '90d': { unit: 'day', count: 90 },
    '12m': { unit: 'month', count: 12 },
};
const TZ = 'Asia/Kolkata';
const IST_OFFSET_MS = 330 * 60 * 1000; // India has no daylight saving

/** Bucket keys (IST dates or months) for the range, plus where it and the previous one start. */
function rangeWindow(rangeKey, now = new Date()) {
    const { unit, count } = RANGES[rangeKey];
    const ist = new Date(now.getTime() + IST_OFFSET_MS);
    const y = ist.getUTCFullYear();
    const m = ist.getUTCMonth();
    const d = ist.getUTCDate();
    const istMidnight = (yy, mm, dd) => new Date(Date.UTC(yy, mm, dd) - IST_OFFSET_MS);

    const keys = [];
    if (unit === 'day') {
        for (let i = count - 1; i >= 0; i--) keys.push(new Date(Date.UTC(y, m, d - i)).toISOString().slice(0, 10));
        return { unit, keys, start: istMidnight(y, m, d - (count - 1)), prevStart: istMidnight(y, m, d - (2 * count - 1)) };
    }
    for (let i = count - 1; i >= 0; i--) keys.push(new Date(Date.UTC(y, m - i, 1)).toISOString().slice(0, 7));
    return { unit, keys, start: istMidnight(y, m - (count - 1), 1), prevStart: istMidnight(y, m - (2 * count - 1), 1) };
}

async function getDashboard(query = {}) {
    const range = RANGES[query.range] ? query.range : '30d';
    const { unit, keys, start, prevStart } = rangeWindow(range);
    const fmt = unit === 'day' ? 'YYYY-MM-DD' : 'YYYY-MM';
    const q = (sql, replacements) => db.sequelize.query(sql, { replacements, type: QueryTypes.SELECT });
    const r = { start, prevStart, unit, fmt, tz: TZ };
    const bucket = `to_char(date_trunc(:unit, "createdAt" AT TIME ZONE :tz), :fmt)`;

    const [[orderTotals], [userTotals], [listingTotals], orderSeries, userSeries, listingSeries, statusRows, recentOrders] = await Promise.all([
        q(`SELECT
             COUNT(*) FILTER (WHERE "createdAt" >= :start AND status <> 'cancelled') AS orders,
             COUNT(*) FILTER (WHERE "createdAt" >= :start AND status = 'cancelled') AS cancelled,
             COALESCE(SUM(${SQL_CASH}) FILTER (WHERE "createdAt" >= :start AND status <> 'cancelled'), 0) AS cash,
             COALESCE(SUM(${SQL_POINTS}) FILTER (WHERE "createdAt" >= :start AND status <> 'cancelled'), 0) AS points,
             COUNT(*) FILTER (WHERE "createdAt" < :start AND status <> 'cancelled') AS prev_orders,
             COALESCE(SUM(${SQL_CASH}) FILTER (WHERE "createdAt" < :start AND status <> 'cancelled'), 0) AS prev_cash,
             COALESCE(SUM(${SQL_POINTS}) FILTER (WHERE "createdAt" < :start AND status <> 'cancelled'), 0) AS prev_points
           FROM tbl_orders WHERE "createdAt" >= :prevStart`, r),
        q(`SELECT COUNT(*) AS total,
             COUNT(*) FILTER (WHERE "createdAt" >= :start) AS new,
             COUNT(*) FILTER (WHERE "createdAt" >= :prevStart AND "createdAt" < :start) AS prev_new
           FROM tbl_users WHERE role IN ('user', 'seller')`, r),
        q(`SELECT COUNT(*) FILTER (WHERE status = 'active') AS active,
             COUNT(*) FILTER (WHERE "createdAt" >= :start) AS new,
             COUNT(*) FILTER (WHERE "createdAt" >= :prevStart AND "createdAt" < :start) AS prev_new
           FROM tbl_products`, r),
        q(`SELECT ${bucket} AS bucket,
             COUNT(*) FILTER (WHERE status <> 'cancelled') AS orders,
             COALESCE(SUM(${SQL_CASH}) FILTER (WHERE status <> 'cancelled'), 0) AS cash,
             COALESCE(SUM(${SQL_POINTS}) FILTER (WHERE status <> 'cancelled'), 0) AS points
           FROM tbl_orders WHERE "createdAt" >= :start GROUP BY 1`, r),
        q(`SELECT ${bucket} AS bucket, COUNT(*) AS n FROM tbl_users
           WHERE role IN ('user', 'seller') AND "createdAt" >= :start GROUP BY 1`, r),
        q(`SELECT ${bucket} AS bucket, COUNT(*) AS n FROM tbl_products WHERE "createdAt" >= :start GROUP BY 1`, r),
        q(`SELECT status, COUNT(*) AS n FROM tbl_orders WHERE "createdAt" >= :start GROUP BY status`, r),
        Order.findAll({
            limit: 5,
            order: [['createdAt', 'DESC']],
            include: [{ model: User, as: 'user', attributes: ['name'] }],
        }),
    ]);

    const byBucket = (rows) => new Map(rows.map((row) => [row.bucket, row]));
    const orderMap = byBucket(orderSeries);
    const userMap = byBucket(userSeries);
    const listingMap = byBucket(listingSeries);

    return {
        range,
        unit,
        from: start.toISOString(),
        totals: {
            users: Number(userTotals.total),
            activeListings: Number(listingTotals.active),
        },
        period: {
            orders: Number(orderTotals.orders),
            cancelledOrders: Number(orderTotals.cancelled),
            cashRevenue: String(orderTotals.cash),
            pointsSpent: String(orderTotals.points),
            newUsers: Number(userTotals.new),
            newListings: Number(listingTotals.new),
        },
        previous: {
            orders: Number(orderTotals.prev_orders),
            cashRevenue: String(orderTotals.prev_cash),
            pointsSpent: String(orderTotals.prev_points),
            newUsers: Number(userTotals.prev_new),
            newListings: Number(listingTotals.prev_new),
        },
        series: keys.map((key) => ({
            bucket: key,
            orders: Number(orderMap.get(key)?.orders || 0),
            cash: Number(orderMap.get(key)?.cash || 0),
            points: Number(orderMap.get(key)?.points || 0),
            newUsers: Number(userMap.get(key)?.n || 0),
            newListings: Number(listingMap.get(key)?.n || 0),
        })),
        statusBreakdown: Object.fromEntries(statusRows.map((row) => [row.status, Number(row.n)])),
        recentOrders,
    };
}

module.exports = {
    AdminError,
    listProducts,
    updateProduct,
    deleteProduct,
    addProductImage,
    removeProductImage,
    reorderProductImages,
    listOrders,
    setOrderStatus,
    listUsers,
    getUserDetail,
    listWallets,
    getWallet,
    adjustWallet,
    listCategories,
    setCategoryVisibility,
    setSubCategoryVisibility,
    getSettings,
    updateSettings,
    getDashboard,
    rangeWindow,
};
