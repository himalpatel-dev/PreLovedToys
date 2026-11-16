const express = require('express');
const router = express.Router();
const verifyToken = require('../middlewares/auth.middleware');
const requireAdmin = require('../middlewares/admin.middleware');
const adminController = require('../controllers/admin.controller');

// Every route here needs a valid token AND an active admin account.
router.use(verifyToken, requireAdmin);

// Dashboard: ?range=7d|30d|90d|12m
router.get('/stats', adminController.getDashboard);

// Paged lists: ?page=1&limit=20&search=...&status=...
router.get('/products', adminController.listProducts); // also ?sellerId=
router.put('/products/:id', adminController.updateProduct);
router.delete('/products/:id', adminController.deleteProduct);
router.post('/products/:id/images', adminController.addProductImage); // { imageUrl }
router.put('/products/:id/images/order', adminController.reorderProductImages); // { imageIds: [...] }
router.delete('/products/:id/images/:imageId', adminController.removeProductImage);

router.get('/orders', adminController.listOrders); // also ?userId= (buyer) and ?sellerId=
router.put('/orders/:id/status', adminController.setOrderStatus); // cancelling refunds points

router.get('/users', adminController.listUsers);
router.get('/users/:id', adminController.getUserDetail);

// Points: balances, history, and manual adjustments
router.get('/wallets', adminController.listWallets);
router.get('/wallets/:userId', adminController.getWallet);
router.post('/wallets/:userId/adjust', adminController.adjustWallet);

// Catalogue incl. hidden entries; show/hide in the app
router.get('/categories', adminController.listCategories);
router.put('/categories/:id/visibility', adminController.setCategoryVisibility); // { isActive }
router.put('/subcategories/:id/visibility', adminController.setSubCategoryVisibility); // { isActive }

// Points rules
router.get('/settings', adminController.getSettings);
router.put('/settings', adminController.updateSettings);

module.exports = router;
