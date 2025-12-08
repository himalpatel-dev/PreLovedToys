const favoriteService = require('../services/favorite.service');

// Add to favorites
const addToFavorites = async (req, res) => {
    try {
        const userId = req.user.id; // From auth middleware
        const { productId } = req.body;

        if (!productId) {
            return res.status(400).json({ message: 'Product ID is required' });
        }

        const favorite = await favoriteService.addFavorite(userId, productId);
        res.status(201).json({ message: 'Added to favorites', favorite });
    } catch (error) {
        if (error.message === 'Product not found') {
            return res.status(404).json({ message: error.message });
        }
        if (error.message === 'Product already in favorites') {
            return res.status(409).json({ message: error.message });
        }
        res.status(500).json({ message: error.message });
    }
};

// Remove from favorites
const removeFromFavorites = async (req, res) => {
    try {
        const userId = req.user.id;
        const { productId } = req.params;

        const result = await favoriteService.removeFavorite(userId, productId);
        res.status(200).json(result);
    } catch (error) {
        if (error.message === 'Favorite not found') {
            return res.status(404).json({ message: error.message });
        }
        res.status(500).json({ message: error.message });
    }
};

// Get user's favorites
const getMyFavorites = async (req, res) => {
    try {
        const userId = req.user.id;
        const favorites = await favoriteService.getUserFavorites(userId);
        res.status(200).json(favorites);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Check if product is favorited
const checkFavoriteStatus = async (req, res) => {
    try {
        const userId = req.user.id;
        const { productId } = req.params;

        const result = await favoriteService.isFavorited(userId, productId);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get favorite count for a product
const getFavoriteCount = async (req, res) => {
    try {
        const { productId } = req.params;
        const result = await favoriteService.getProductFavoriteCount(productId);
        res.status(200).json(result);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get user's favorites
const getMyFavoritesProductId = async (req, res) => {
    try {
        const userId = req.user.id;
        const favorites = await favoriteService.getUserFavoritesProductId(userId);
        res.status(200).json(favorites);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    addToFavorites,
    removeFromFavorites,
    getMyFavorites,
    checkFavoriteStatus,
    getFavoriteCount,
    getMyFavoritesProductId
};
