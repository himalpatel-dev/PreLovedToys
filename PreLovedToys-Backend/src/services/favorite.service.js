const db = require('../models');
const Favorite = db.Favorite;
const Product = db.Product;
const ProductImage = db.ProductImage;
const Category = db.Category;
const SubCategory = db.SubCategory;
const User = db.User;

// 1. Add product to favorites
const addFavorite = async (userId, productId) => {
    try {
        // Check if product exists
        const product = await Product.findByPk(productId);
        if (!product) {
            throw new Error('Product not found');
        }

        // Check if already favorited
        const existingFavorite = await Favorite.findOne({
            where: { userId, productId }
        });

        if (existingFavorite) {
            throw new Error('Product already in favorites');
        }

        // Create favorite
        const favorite = await Favorite.create({
            userId,
            productId
        });

        return favorite;
    } catch (error) {
        throw error;
    }
};

// 2. Remove product from favorites
const removeFavorite = async (userId, productId) => {
    try {
        const favorite = await Favorite.findOne({
            where: { userId, productId }
        });

        if (!favorite) {
            throw new Error('Favorite not found');
        }

        await favorite.destroy();
        return { message: 'Removed from favorites' };
    } catch (error) {
        throw error;
    }
};

// 3. Get all favorites for a user
const getUserFavorites = async (userId) => {
    try {
        const favorites = await Favorite.findAll({
            where: { userId },
            include: [
                {
                    model: Product,
                    as: 'product',
                    include: [
                        { model: ProductImage, as: 'images', attributes: ['imageUrl', 'isPrimary'] },
                        { model: Category, as: 'category', attributes: ['name'] },
                        { model: SubCategory, as: 'subcategory', attributes: ['name'] },
                        { model: User, as: 'seller', attributes: ['name'] }
                    ]
                }
            ],
            order: [['createdAt', 'DESC']]
        });

        return favorites;
    } catch (error) {
        throw error;
    }
};

//get all favorutes for user retrun only productid 
const getUserFavoritesProductId = async (userId) => {
    try {
        const favorites = await Favorite.findAll({
            where: { userId },
            attributes: ['productId']
        });

        return favorites;
    } catch (error) {
        throw error;
    }
};

// 4. Check if a product is favorited by user
const isFavorited = async (userId, productId) => {
    try {
        const favorite = await Favorite.findOne({
            where: { userId, productId }
        });

        return { isFavorited: !!favorite };
    } catch (error) {
        throw error;
    }
};

// 5. Get favorite count for a product
const getProductFavoriteCount = async (productId) => {
    try {
        const count = await Favorite.count({
            where: { productId }
        });

        return { count };
    } catch (error) {
        throw error;
    }
};

module.exports = {
    addFavorite,
    removeFavorite,
    getUserFavorites,
    getUserFavoritesProductId,
    isFavorited,
    getProductFavoriteCount
};
