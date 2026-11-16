const { Op } = require('sequelize');
const db = require('../models');
const AppError = require('../utils/app-error');
const settingsService = require('./settings.service');

const Product = db.Product;
const ProductImage = db.ProductImage;
const Category = db.Category;
const User = db.User;
const AgeGroup = db.AgeGroup;
const Color = db.Color;
const Gender = db.Gender;
const Material = db.Material;
const SubCategory = db.SubCategory;

const CONDITIONS = ['New', 'Like New', 'Good', 'Fair'];
const MAX_IMAGES = 10;
const IMAGE_ATTRS = ['id', 'imageUrl', 'isPrimary', 'sortOrder'];
const IMAGE_ORDER = [['sortOrder', 'ASC'], ['id', 'ASC']];
/** Images as a separate query so they keep their display order (and work with paging). */
const imagesInclude = () => ({ model: ProductImage, as: 'images', attributes: IMAGE_ATTRS, separate: true, order: IMAGE_ORDER });

// ---------- small helpers ----------

function parseId(value, label = 'id') {
    const id = Number(value);
    if (!Number.isInteger(id) || id < 1) throw new AppError(`Invalid ${label}.`);
    return id;
}

/** Case-insensitive "contains" with LIKE wildcards escaped. */
function contains(text) {
    return { [Op.iLike]: `%${text.replace(/[\\%_]/g, '\\$&')}%` };
}

/**
 * Stored image values are bare upload filenames or full http(s) URLs. The model getter turns
 * filenames into `${BASE_URL}/uploads/<file>`, so a URL sent back by a client is turned back
 * into the filename before saving.
 */
function normalizeImageValue(value) {
    if (typeof value !== 'string' || !value.trim()) throw new AppError('Each image must be a file name or URL.');
    let v = value.trim();
    const prefix = `${process.env.BASE_URL}/uploads/`;
    if (process.env.BASE_URL && v.startsWith(prefix)) v = v.slice(prefix.length);
    else if (v.startsWith('/uploads/')) v = v.slice('/uploads/'.length);
    if (v.length > 500) throw new AppError('Image URL is too long.');
    if (!/^https?:\/\//i.test(v) && !/^[\w.-]+$/.test(v)) throw new AppError('Invalid image file name.');
    return v;
}

/** Where-clauses that hide listings in hidden (isActive = false) categories or sub-categories. */
async function visibleCatalogConditions() {
    const [cats, subs] = await Promise.all([
        Category.findAll({ attributes: ['id'], where: { isActive: false } }),
        SubCategory.findAll({ attributes: ['id'], where: { isActive: false } }),
    ]);
    const conditions = [];
    if (cats.length) {
        conditions.push({ [Op.or]: [{ categoryId: null }, { categoryId: { [Op.notIn]: cats.map((c) => c.id) } }] });
    }
    if (subs.length) {
        conditions.push({ [Op.or]: [{ subCategoryId: null }, { subCategoryId: { [Op.notIn]: subs.map((s) => s.id) } }] });
    }
    return conditions;
}

// ---------- create ----------

const createProduct = async (data, userId) => {
    // Validate isPoints flag: rupee listings unlock after enough point-based sales.
    const isPoints = data.isPoints !== undefined ? data.isPoints : true;
    if (!isPoints) {
        const eligibility = await getSellEligibility(userId);
        if (!eligibility.canSellCash) {
            throw new AppError(
                `You must complete at least ${eligibility.requiredSales} point-based sales before unlocking real money listings. ` +
                `Current: ${eligibility.completedPointsSales}/${eligibility.requiredSales}`, 403
            );
        }
    }

    return db.sequelize.transaction(async (transaction) => {
        const newProduct = await Product.create({
            title: data.title,
            description: data.description,
            price: data.price,
            isPoints: isPoints,
            condition: data.condition,
            categoryId: data.categoryId,
            subCategoryId: data.subCategoryId || null,
            ageGroupId: data.ageGroupId,
            genderId: data.genderId,
            colorId: data.colorId,
            materialId: data.materialId || null, // Optional
            userId: userId
        }, { transaction });

        if (Array.isArray(data.images) && data.images.length > 0) {
            const imageObjects = data.images.slice(0, MAX_IMAGES).map((url, index) => ({
                productId: newProduct.id,
                imageUrl: normalizeImageValue(url),
                isPrimary: index === 0,
                sortOrder: index
            }));
            await ProductImage.bulkCreate(imageObjects, { transaction });
        }
        return newProduct;
    });
};

// ---------- app lists (active listings only) ----------

const listIncludes = () => [
    imagesInclude(),
    { model: Category, as: 'category', attributes: ['id', 'name'] },
    { model: SubCategory, as: 'subcategory', attributes: ['id', 'name'] },
    { model: User, as: 'seller', attributes: ['id', 'name'] },
];

const SORTS = {
    newest: [['createdAt', 'DESC'], ['id', 'DESC']],
    oldest: [['createdAt', 'ASC'], ['id', 'ASC']],
    price_asc: [['price', 'ASC'], ['id', 'DESC']],
    price_desc: [['price', 'DESC'], ['id', 'DESC']],
};

/**
 * Active listings for the app, with optional filters and search.
 *
 * filters: search, categoryId, subCategoryId, ageGroupId, genderId, colorId, materialId,
 *          isPoints ('true'|'false'), minPrice, maxPrice, sort (newest|oldest|price_asc|price_desc),
 *          page, limit
 * options.excludeUserId hides one seller's own listings.
 *
 * Without `page`/`limit` it returns a plain array (what the app has always received).
 * With them it returns { data, total, page, limit, hasMore }.
 */
async function listActiveProducts(filters = {}, options = {}) {
    const where = { status: 'active' };
    const and = await visibleCatalogConditions();

    for (const [key, label] of [
        ['categoryId', 'category'], ['subCategoryId', 'sub-category'], ['ageGroupId', 'age group'],
        ['genderId', 'gender'], ['colorId', 'color'], ['materialId', 'material'],
    ]) {
        if (filters[key] !== undefined && filters[key] !== '') where[key] = parseId(filters[key], label);
    }
    if (filters.isPoints === 'true' || filters.isPoints === true) where.isPoints = true;
    if (filters.isPoints === 'false' || filters.isPoints === false) where.isPoints = false;

    const price = {};
    if (filters.minPrice !== undefined && filters.minPrice !== '') {
        const min = Number(filters.minPrice);
        if (!Number.isFinite(min) || min < 0) throw new AppError('minPrice must be 0 or more.');
        price[Op.gte] = Math.floor(min);
    }
    if (filters.maxPrice !== undefined && filters.maxPrice !== '') {
        const max = Number(filters.maxPrice);
        if (!Number.isFinite(max) || max < 0) throw new AppError('maxPrice must be 0 or more.');
        price[Op.lte] = Math.ceil(max);
    }
    if (Object.getOwnPropertySymbols(price).length) where.price = price;

    if (options.excludeUserId) where.userId = { [Op.ne]: options.excludeUserId };

    const search = typeof filters.search === 'string' ? filters.search.trim().slice(0, 100) : '';
    if (search) {
        const [cats, subs] = await Promise.all([
            Category.findAll({ attributes: ['id'], where: { name: contains(search) } }),
            SubCategory.findAll({ attributes: ['id'], where: { name: contains(search) } }),
        ]);
        const or = [{ title: contains(search) }, { description: contains(search) }];
        if (cats.length) or.push({ categoryId: cats.map((c) => c.id) });
        if (subs.length) or.push({ subCategoryId: subs.map((s) => s.id) });
        and.push({ [Op.or]: or });
    }
    if (and.length) where[Op.and] = and;

    const order = SORTS[filters.sort] || SORTS.newest;
    const paged = filters.page !== undefined || filters.limit !== undefined;

    if (!paged) {
        return Product.findAll({ where, include: listIncludes(), order });
    }

    const page = Math.max(1, parseInt(filters.page, 10) || 1);
    const limit = Math.min(100, Math.max(1, parseInt(filters.limit, 10) || 20));
    const { rows, count } = await Product.findAndCountAll({
        where, include: listIncludes(), order, limit, offset: (page - 1) * limit, distinct: true,
    });
    return { data: rows, total: count, page, limit, hasMore: page * limit < count };
}

/** Kept for existing callers: GET /products?categoryId=&subCategoryId= */
const getAllProducts = (filters = {}) => listActiveProducts(filters);

// ---------- single listing ----------

const getProductById = async (id) => {
    const productId = Number(id);
    if (!Number.isInteger(productId) || productId < 1) throw new AppError('Product not found', 404);

    const product = await Product.findByPk(productId, {
        include: [
            imagesInclude(),
            { model: Category, as: 'category', attributes: ['id', 'name'] },
            { model: SubCategory, as: 'subcategory', attributes: ['id', 'name'] },
            { model: User, as: 'seller', attributes: ['id', 'name', 'mobile'] },
            { model: AgeGroup, as: 'ageGroup', attributes: ['id', 'name'] },
            { model: Color, as: 'color', attributes: ['id', 'name', 'hexCode'] },
            { model: Gender, as: 'gender', attributes: ['id', 'name'] },
            { model: Material, as: 'material', attributes: ['id', 'name'] }
        ]
    });

    if (!product) throw new AppError('Product not found', 404);
    return product;
};

const updateProductStatus = async (id, status) => {
    const product = await Product.findByPk(id);
    if (!product) throw new Error('Product not found');
    product.status = status;
    return await product.save();
};

const getUserProducts = async (userId) => {
    return await Product.findAll({
        where: { userId },
        include: [imagesInclude()],
        order: [['updatedAt', 'DESC']]
    });
};

const deleteProduct = async (productId, userId) => {
    const product = await Product.findOne({ where: { id: productId, userId } });

    if (!product) {
        throw new Error('Product not found or you are not the owner');
    }

    return await product.destroy();
};

const getAdminProducts = async () => {
    return Product.findAll({
        include: [
            imagesInclude(),
            { model: Category, as: 'category', attributes: ['name'] },
            { model: SubCategory, as: 'subcategory', attributes: ['name'] },
            { model: User, as: 'seller', attributes: ['id', 'name', 'mobile'] },
        ],
        order: [['createdAt', 'DESC']]
    });
};

// ---------- selling rules ----------

const getCompletedPointsSalesCount = async (userId) => {
    return Product.count({ where: { userId, status: 'sold', isPoints: true } });
};

/** Whether a seller may list items for rupees, and a message explaining why not. */
async function getSellEligibility(userId) {
    const [count, required] = await Promise.all([
        getCompletedPointsSalesCount(userId),
        settingsService.get('cashUnlockSales'),
    ]);
    const canSellCash = count >= required;
    const remaining = Math.max(required - count, 0);
    return {
        completedPointsSales: count,
        requiredSales: required,
        canSellCash,
        canSellRealMoney: canSellCash, // older name, kept for existing clients
        message: canSellCash
            ? 'You can now sell for real money!'
            : `You have ${count}/${required} completed point-based sales. Complete ${remaining} more sale(s) to unlock real money selling.`
    };
}

// ---------- editing (shared by sellers and admins) ----------

/** Optional reference to a master table: null/'' clears it, otherwise the row must exist. */
async function optionalRef(Model, value, label) {
    if (value === null || value === undefined || value === '') return null;
    const id = parseId(value, label);
    if (!(await Model.findByPk(id, { attributes: ['id'] }))) throw new AppError(`${label} not found.`);
    return id;
}

/**
 * Validates the editable details in `body` against `product` and returns the changes.
 * Only fields present in body are considered. Category and sub-category are checked together.
 */
async function buildDetailChanges(product, body = {}) {
    const changes = {};
    const has = (key) => Object.prototype.hasOwnProperty.call(body, key);

    if (has('title')) {
        const title = typeof body.title === 'string' ? body.title.trim() : '';
        if (!title) throw new AppError('Title is required.');
        if (title.length > 255) throw new AppError('Title must be 255 characters or fewer.');
        changes.title = title;
    }
    if (has('description')) {
        const description = typeof body.description === 'string' ? body.description.trim() : '';
        if (!description) throw new AppError('Description is required.');
        if (description.length > 5000) throw new AppError('Description must be 5000 characters or fewer.');
        changes.description = description;
    }
    if (has('price')) {
        const price = Number(body.price);
        if (!Number.isInteger(price) || price < 0 || price > 100000000) {
            throw new AppError('Price must be a whole number from 0 to 100,000,000.');
        }
        changes.price = price;
    }
    if (has('isPoints')) {
        if (typeof body.isPoints !== 'boolean') throw new AppError('isPoints must be true or false.');
        changes.isPoints = body.isPoints;
    }
    if (has('condition')) {
        if (!CONDITIONS.includes(body.condition)) throw new AppError(`Condition must be one of: ${CONDITIONS.join(', ')}.`);
        changes.condition = body.condition;
    }

    if (has('categoryId') || has('subCategoryId')) {
        const categoryId = has('categoryId') ? body.categoryId : product.categoryId;
        const subCategoryId = has('subCategoryId') ? body.subCategoryId : product.subCategoryId;
        const catId = parseId(categoryId, 'category');
        if (!(await Category.findByPk(catId, { attributes: ['id'] }))) throw new AppError('Category not found.');
        let subId = null;
        if (subCategoryId !== null && subCategoryId !== undefined && subCategoryId !== '') {
            subId = parseId(subCategoryId, 'sub-category');
            const sub = await SubCategory.findByPk(subId, { attributes: ['id', 'categoryId'] });
            if (!sub) throw new AppError('Sub-category not found.');
            if (sub.categoryId !== catId) throw new AppError('That sub-category belongs to a different category.');
        }
        changes.categoryId = catId;
        changes.subCategoryId = subId;
    }

    if (has('ageGroupId')) changes.ageGroupId = await optionalRef(AgeGroup, body.ageGroupId, 'Age group');
    if (has('genderId')) changes.genderId = await optionalRef(Gender, body.genderId, 'Gender');
    if (has('colorId')) changes.colorId = await optionalRef(Color, body.colorId, 'Color');
    if (has('materialId')) changes.materialId = await optionalRef(Material, body.materialId, 'Material');

    return changes;
}

/** Re-numbers a listing's photos 0..n-1 in their current order and marks the first as cover. */
async function renumberImages(productId, transaction, orderedIds) {
    const images = await ProductImage.findAll({ where: { productId }, order: IMAGE_ORDER, transaction });
    const ids = orderedIds || images.map((i) => i.id);
    for (const [index, id] of ids.entries()) {
        await ProductImage.update({ sortOrder: index, isPrimary: index === 0 }, { where: { id, productId }, transaction });
    }
}

/**
 * A seller edits their own listing: the same details admins can edit, plus optionally
 * `images` (an array of upload file names / URLs) which replaces all photos in that order.
 * Sold listings cannot be edited, and switching to rupees follows the unlock rule.
 */
async function updateOwnListing(productId, userId, body = {}) {
    const id = parseId(productId, 'product id');
    const product = await Product.findByPk(id);
    if (!product || product.userId !== userId) throw new AppError('Product not found or you are not the owner', 404);
    if (product.status === 'sold') throw new AppError("Sold listings can't be edited.", 409);

    const changes = await buildDetailChanges(product, body);

    if (changes.isPoints === false && product.isPoints !== false) {
        const eligibility = await getSellEligibility(userId);
        if (!eligibility.canSellCash) throw new AppError(eligibility.message, 403);
    }

    let images = null;
    if (Object.prototype.hasOwnProperty.call(body, 'images')) {
        if (!Array.isArray(body.images) || body.images.length < 1) throw new AppError('A listing needs at least one photo.');
        if (body.images.length > MAX_IMAGES) throw new AppError(`A listing can have at most ${MAX_IMAGES} photos.`);
        images = body.images.map(normalizeImageValue);
    }

    if (!Object.keys(changes).length && !images) throw new AppError('Nothing to update.');

    await db.sequelize.transaction(async (transaction) => {
        if (Object.keys(changes).length) await product.update(changes, { transaction });
        if (images) {
            await ProductImage.destroy({ where: { productId: id }, transaction });
            await ProductImage.bulkCreate(
                images.map((imageUrl, index) => ({ productId: id, imageUrl, isPrimary: index === 0, sortOrder: index })),
                { transaction }
            );
        }
    });
    return getProductById(id);
}

// ---------- photo management (used by the admin portal) ----------

async function addImage(productId, imageUrl) {
    const id = parseId(productId, 'product id');
    const value = normalizeImageValue(imageUrl);
    await db.sequelize.transaction(async (transaction) => {
        const product = await Product.findByPk(id, { transaction, lock: transaction.LOCK.UPDATE });
        if (!product) throw new AppError('Product not found.', 404);
        const count = await ProductImage.count({ where: { productId: id }, transaction });
        if (count >= MAX_IMAGES) throw new AppError(`A listing can have at most ${MAX_IMAGES} photos.`);
        await ProductImage.create({ productId: id, imageUrl: value, isPrimary: count === 0, sortOrder: count }, { transaction });
        await renumberImages(id, transaction);
    });
    return getProductById(id);
}

async function removeImage(productId, imageId) {
    const id = parseId(productId, 'product id');
    const imgId = parseId(imageId, 'image id');
    await db.sequelize.transaction(async (transaction) => {
        const product = await Product.findByPk(id, { transaction, lock: transaction.LOCK.UPDATE });
        if (!product) throw new AppError('Product not found.', 404);
        const image = await ProductImage.findOne({ where: { id: imgId, productId: id }, transaction });
        if (!image) throw new AppError('Photo not found.', 404);
        const count = await ProductImage.count({ where: { productId: id }, transaction });
        if (count <= 1) throw new AppError('A listing needs at least one photo. Add another photo before removing this one.');
        await image.destroy({ transaction });
        await renumberImages(id, transaction);
    });
    return getProductById(id);
}

/** `imageIds` must list every photo of the listing exactly once, in the new order. */
async function reorderImages(productId, imageIds) {
    const id = parseId(productId, 'product id');
    if (!Array.isArray(imageIds) || !imageIds.length) throw new AppError('imageIds must be a list of photo ids.');
    const ids = imageIds.map((v) => parseId(v, 'image id'));
    await db.sequelize.transaction(async (transaction) => {
        const product = await Product.findByPk(id, { transaction, lock: transaction.LOCK.UPDATE });
        if (!product) throw new AppError('Product not found.', 404);
        const existing = (await ProductImage.findAll({ where: { productId: id }, attributes: ['id'], transaction })).map((i) => i.id);
        const same = existing.length === ids.length && new Set(ids).size === ids.length && ids.every((x) => existing.includes(x));
        if (!same) throw new AppError("The photo list doesn't match this listing's photos. Reload and try again.", 409);
        await renumberImages(id, transaction, ids);
    });
    return getProductById(id);
}

module.exports = {
    CONDITIONS,
    createProduct,
    getAllProducts,
    listActiveProducts,
    getProductById,
    updateProductStatus,
    getUserProducts,
    deleteProduct,
    getAdminProducts,
    getCompletedPointsSalesCount,
    getSellEligibility,
    buildDetailChanges,
    updateOwnListing,
    addImage,
    removeImage,
    reorderImages,
};
