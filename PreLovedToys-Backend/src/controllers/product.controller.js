const productService = require('../services/product.service');

const addProduct = async (req, res) => {
    try {
        // req.user.id comes from the middleware!
        const userId = req.user.id;

        const product = await productService.createProduct(req.body, userId);
        res.status(201).json({ message: "Product listed successfully", product });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getProducts = async (req, res) => {
    try {
        const { status } = req.query; // Read ?status=pending from URL
        const products = await productService.getAllProducts(status || 'active');
        res.status(200).json(products);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getProductById = async (req, res) => {
    try {
        const { id } = req.params;
        const product = await productService.getProductById(id);
        res.status(200).json(product);
    } catch (error) {
        // If error is "Product not found", return 404
        if (error.message === 'Product not found') {
            return res.status(404).json({ message: error.message });
        }
        res.status(500).json({ message: error.message });
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
        res.status(500).json({ message: error.message });
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

module.exports = {
    addProduct,
    getProducts,
    getProductById,
    updateStatus,
    getMyListings,
    deleteListing
};