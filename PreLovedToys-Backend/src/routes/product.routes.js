const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');
const verifyToken = require('../middlewares/auth.middleware');

router.use(verifyToken); // Protect all routes

// 1. Specific Routes MUST be at the top
router.post('/', productController.addProduct);
router.get('/my-listings', productController.getMyListings); // <--- MOVE THIS HERE
router.get('/sales-count/points', productController.getPointsSalesCount); // Get completed points-based sales count

// 2. General "Get All" route
router.get('/', productController.getProducts);

// 3. Variable ID Routes MUST be at the bottom
// Because this acts like a wildcard, it will try to capture "my-listings" if placed above.
router.get('/:id', productController.getProductById);

// 4. Delete route (also uses ID)
router.delete('/:id', productController.deleteListing);

// PUT /api/products/:id/status
router.put('/:id/status', productController.updateStatus);

// ADMIN ROUTES
router.get('/admin/all', productController.getAllProductsAdmin);

module.exports = router;