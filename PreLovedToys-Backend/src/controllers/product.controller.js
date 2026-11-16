const productService = require('../services/product.service');

/** Sends AppError status codes (400/403/404/409); anything else is a 500. */
const sendError = (res, error) => {
    const status = error.status || 500;
    if (status === 500) console.error('[products]', error);
    res.status(status).json({ message: error.message });
};

const addProduct = async (req, res) => {
    try {
        // req.user.id comes from the middleware!
        const userId = req.user.id;

        const product = await productService.createProduct(req.body, userId);
        res.status(201).json({ message: "Product listed successfully", product });
    } catch (error) {
        sendError(res, error);
    }
};

/**
 * GET /api/products
 * Filters: search, categoryId, subCategoryId, ageGroupId, genderId, colorId, materialId,
 *          isPoints, minPrice, maxPrice, sort (newest|oldest|price_asc|price_desc)
 * Paging: add ?page=1&limit=20 to get { data, total, page, limit, hasMore }.
 * Without page/limit it returns a plain array, as before.
 */
const getProducts = async (req, res) => {
    try {
        res.status(200).json(await productService.listActiveProducts(req.query));
    } catch (error) {
        sendError(res, error);
    }
};

/** GET /api/products/sub-category/:subCategoryId (same filters and paging as GET /products) */
const getProductsBySubCategory = async (req, res) => {
    try {
        const filters = { ...req.query, subCategoryId: req.params.subCategoryId };
        res.status(200).json(await productService.listActiveProducts(filters));
    } catch (error) {
        sendError(res, error);
    }
};

/** GET /api/products/other-listings: active listings from everyone except the signed-in user */
const getOtherListings = async (req, res) => {
    try {
        res.status(200).json(await productService.listActiveProducts(req.query, { excludeUserId: req.user.id }));
    } catch (error) {
        sendError(res, error);
    }
};

const getProductById = async (req, res) => {
    try {
        const { id } = req.params;
        const product = await productService.getProductById(id);
        res.status(200).json(product);
    } catch (error) {
        sendError(res, error);
    }
};

/** PUT /api/products/:id: the owner edits their listing (details and, optionally, images) */
const updateListing = async (req, res) => {
    try {
        const product = await productService.updateOwnListing(req.params.id, req.user.id, req.body);
        res.status(200).json({ message: 'Listing updated', product });
    } catch (error) {
        sendError(res, error);
    }
};

const updateStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body; // { "status": "active" }
        await productService.updateProductStatus(id, status);
        res.json({ message: "Status updated" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getMyListings = async (req, res) => {
    try {
        const userId = req.user.id; // From Token
        const products = await productService.getUserProducts(userId);
        res.status(200).json(products);
    } catch (error) {
        sendError(res, error);
    }
};

/** GET /api/products/sales-count/points (older name for sell-eligibility) */
const getPointsSalesCount = async (req, res) => {
    try {
        res.status(200).json(await productService.getSellEligibility(req.user.id));
    } catch (error) {
        sendError(res, error);
    }
};

/** GET /api/products/sell-eligibility: { canSellCash, message, completedPointsSales, requiredSales } */
const getSellEligibility = async (req, res) => {
    try {
        res.status(200).json(await productService.getSellEligibility(req.user.id));
    } catch (error) {
        sendError(res, error);
    }
};

const deleteListing = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        await productService.deleteProduct(id, userId);
        res.status(200).json({ message: "Product deleted successfully" });
    } catch (error) {
        res.status(403).json({ message: error.message });
    }
};

const getAllProductsAdmin = async (req, res) => {
    try {
        const products = await productService.getAdminProducts();
        res.status(200).json(products);
    } catch (error) {
        sendError(res, error);
    }
};

module.exports = {
    addProduct,
    getProducts,
    getProductsBySubCategory,
    getOtherListings,
    getProductById,
    updateListing,
    updateStatus,
    getMyListings,
    getPointsSalesCount,
    getSellEligibility,
    deleteListing,
    getAllProductsAdmin
};
