const express = require('express');
const router = express.Router();
const favoriteController = require('../controllers/favorite.controller');
const verifyToken = require('../middlewares/auth.middleware');

router.use(verifyToken); // Protect all routes

// 1. Specific routes first
router.get('/my-favorites', favoriteController.getMyFavorites); // Get user's favorites
router.post('/', favoriteController.addToFavorites); // Add to favorites

// 2. Variable ID routes
router.delete('/:productId', favoriteController.removeFromFavorites); // Remove from favorites
router.get('/check/:productId', favoriteController.checkFavoriteStatus); // Check if favorited
router.get('/count/:productId', favoriteController.getFavoriteCount); // Get favorite count
router.get('/my-favorites-product-id', favoriteController.getMyFavoritesProductId); // Get user's favorites

module.exports = router;
