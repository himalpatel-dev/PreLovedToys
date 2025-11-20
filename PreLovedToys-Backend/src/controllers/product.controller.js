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
        const products = await productService.getAllProducts();
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

module.exports = {
    addProduct,
    getProducts,
    getProductById
};