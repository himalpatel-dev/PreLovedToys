const db = require('../models');
const Product = db.Product;
const ProductImage = db.ProductImage; // <-- Import
const Category = db.Category;
const User = db.User;

// 1. Create Product with Images
const createProduct = async (data, userId) => {
    try {
        // A. Create the Product first
        const newProduct = await Product.create({
            title: data.title,
            description: data.description,
            price: data.price,
            condition: data.condition,
            ageGroup: data.ageGroup,
            categoryId: data.categoryId,
            userId: userId
        });

        // B. If there are images, save them to the ProductImage table
        // data.images comes as ["url1", "url2"] from frontend
        if (data.images && data.images.length > 0) {

            // Convert ["url1", "url2"] to [{ productId: 1, imageUrl: "url1" }, ...]
            const imageObjects = data.images.map((url, index) => ({
                productId: newProduct.id,
                imageUrl: url,
                isPrimary: index === 0 // First image is primary
            }));

            // Bulk create inserts multiple rows at once
            await ProductImage.bulkCreate(imageObjects);
        }

        return newProduct;
    } catch (error) {
        throw error;
    }
};

// 2. Get All Products
const getAllProducts = async () => {
    try {
        const products = await Product.findAll({
            where: { status: 'active' },
            include: [
                {
                    model: ProductImage, // <-- Include Images Table
                    as: 'images',
                    attributes: ['imageUrl', 'isPrimary']
                },
                {
                    model: Category,
                    as: 'category',
                    attributes: ['id', 'name']
                },
                {
                    model: User,
                    as: 'seller',
                    attributes: ['id', 'name', 'mobile']
                }
            ],
            order: [['createdAt', 'DESC']]
        });
        return products;
    } catch (error) {
        throw error;
    }
};

const getProductById = async (id) => {
    try {
        const product = await Product.findByPk(id, {
            include: [
                {
                    model: ProductImage,
                    as: 'images',
                    attributes: ['imageUrl', 'isPrimary']
                },
                {
                    model: Category,
                    as: 'category',
                    attributes: ['id', 'name']
                },
                {
                    model: User,
                    as: 'seller',
                    attributes: ['id', 'name', 'mobile']
                }
            ]
        });

        if (!product) {
            throw new Error('Product not found');
        }

        return product;
    } catch (error) {
        throw error;
    }
};

module.exports = {
    createProduct,
    getAllProducts,
    getProductById
};