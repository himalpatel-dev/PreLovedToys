const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');
const verifyToken = require('../middlewares/auth.middleware');

// 1. Specific Routes MUST be at the top
router.post('/', verifyToken, productController.addProduct);
router.get('/my-listings', verifyToken, productController.getMyListings); // <--- MOVE THIS HERE

// 2. General "Get All" route
router.get('/', productController.getProducts);

// 3. Variable ID Routes MUST be at the bottom
// Because this acts like a wildcard, it will try to capture "my-listings" if placed above.
router.get('/:id', productController.getProductById);

// 4. Delete route (also uses ID)
router.delete('/:id', verifyToken, productController.deleteListing);

// PUT /api/products/:id/status
router.put('/:id/status', verifyToken, productController.updateStatus);

module.exports = router;