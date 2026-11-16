const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');
const verifyToken = require('../middlewares/auth.middleware');

router.use(verifyToken); // Protect all routes

// 1. Specific routes MUST come before "/:id", which would otherwise capture them.
router.post('/', productController.addProduct);
router.get('/my-listings', productController.getMyListings);
router.get('/sell-eligibility', productController.getSellEligibility);
router.get('/sales-count/points', productController.getPointsSalesCount); // older name, same data
router.get('/other-listings', productController.getOtherListings);
router.get('/sub-category/:subCategoryId', productController.getProductsBySubCategory);
router.get('/admin/all', productController.getAllProductsAdmin);

// 2. Browse / search active listings (array, or paged with ?page=&limit=)
router.get('/', productController.getProducts);

// 3. Single listing
router.get('/:id', productController.getProductById);
router.put('/:id', productController.updateListing); // owner edits their listing
router.delete('/:id', productController.deleteListing);
router.put('/:id/status', productController.updateStatus);

module.exports = router;
