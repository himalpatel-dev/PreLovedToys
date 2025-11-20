const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');
const verifyToken = require('../middlewares/auth.middleware');

// POST /api/products (Protected: Needs Token)
router.post('/', verifyToken, productController.addProduct);

// GET /api/products (Public: Anyone can see)
router.get('/', productController.getProducts);

module.exports = router;