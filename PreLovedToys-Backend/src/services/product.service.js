const db = require('../models');
const Product = db.Product;
const ProductImage = db.ProductImage; // <-- Import
const Category = db.Category;
const User = db.User;
const AgeGroup = db.AgeGroup;
const Color = db.Color;
const Gender = db.Gender;
const Material = db.Material;
const SubCategory = db.SubCategory;

// 1. Create Product with Images
const createProduct = async (data, userId) => {
    try {
        // Count user's completed sales using points
        const completedPointsSales = await Product.count({
            where: {
                userId: userId,
                status: 'sold',
                isPoints: true
            }
        });

        // Validate isPoints flag
        let isPoints = data.isPoints !== undefined ? data.isPoints : true;
        
        if (!isPoints && completedPointsSales < 3) {
            throw new Error(`You must complete at least 3 point-based sales before unlocking real money listings. Current: ${completedPointsSales}/3`);
        }

        const newProduct = await Product.create({
            title: data.title,
            description: data.description,
            price: data.price,
            isPoints: isPoints,  // Add isPoints field
            condition: data.condition,

            // NEW FIELDS
            categoryId: data.categoryId,
            subCategoryId: data.subCategoryId || null,
            ageGroupId: data.ageGroupId,
            genderId: data.genderId,
            colorId: data.colorId,
            materialId: data.materialId || null, // Optional

            userId: userId
        });

        if (data.images && data.images.length > 0) {
            const imageObjects = data.images.map((url, index) => ({
                productId: newProduct.id,
                imageUrl: url,
                isPrimary: index === 0
            }));
            await ProductImage.bulkCreate(imageObjects);
        }

        return newProduct;
    } catch (error) {
        throw error;
    }
};

// 2. Get All Products (Updated to Include Master Data names)
// Update the arguments to accept an object of filters
const getAllProducts = async (filters = {}) => {
    try {
        // Build the "Where" clause dynamically
        const whereClause = { status: 'active' };

        if (filters.categoryId) {
            whereClause.categoryId = filters.categoryId;
        }
        if (filters.subCategoryId) {
            whereClause.subCategoryId = filters.subCategoryId;
        }

        const products = await Product.findAll({
            where: whereClause, // <--- USE DYNAMIC WHERE CLAUSE
            include: [
                { model: ProductImage, as: 'images', attributes: ['imageUrl', 'isPrimary'] },
                { model: Category, as: 'category', attributes: ['name'] },
                { model: SubCategory, as: 'subcategory', attributes: ['name'] },
                { model: User, as: 'seller', attributes: ['name'] },
                // ... (keep your other includes: AgeGroup, Color, etc.) ...
            ],
            order: [['createdAt', 'DESC']]
        });
        return products;
    } catch (error) {
        throw error;
    }
};

// 3. Get Product By ID (Same update as getAllProducts)
const getProductById = async (id) => {
    try {
        const product = await Product.findByPk(id, {
            include: [
                { model: ProductImage, as: 'images', attributes: ['imageUrl', 'isPrimary'] },
                { model: Category, as: 'category', attributes: ['id', 'name'] },
                { model: SubCategory, as: 'subcategory', attributes: ['id', 'name'] },
                { model: User, as: 'seller', attributes: ['id', 'name', 'mobile'] },
                // INCLUDE NEW MASTERS
                { model: AgeGroup, as: 'ageGroup', attributes: ['id', 'name'] },
                { model: Color, as: 'color', attributes: ['id', 'name', 'hexCode'] },
                { model: Gender, as: 'gender', attributes: ['id', 'name'] },
                { model: Material, as: 'material', attributes: ['id', 'name'] }
            ]
        });

        if (!product) throw new Error('Product not found');
        return product;
    } catch (error) {
        throw error;
    }
};

const updateProductStatus = async (id, status) => {
    const product = await Product.findByPk(id);
    if (!product) throw new Error('Product not found');
    product.status = status;
    return await product.save();
};

const getUserProducts = async (userId) => {
    return await Product.findAll({
        where: { userId },
        include: [{ model: ProductImage, as: 'images' }], // Show images
        order: [['createdAt', 'DESC']]
    });
};

const deleteProduct = async (productId, userId) => {
    const product = await Product.findOne({ where: { id: productId, userId } });

    if (!product) {
        throw new Error('Product not found or you are not the owner');
    }

    // Note: Sequelize will automatically delete related Images if 'cascade' is set, 
    // but for now, simple delete is fine.
    return await product.destroy();
};

const getAdminProducts = async () => {
    try {
        const products = await Product.findAll({
            include: [
                { model: ProductImage, as: 'images', attributes: ['imageUrl', 'isPrimary'] },
                { model: Category, as: 'category', attributes: ['name'] },
                { model: SubCategory, as: 'subcategory', attributes: ['name'] },
                { model: User, as: 'seller', attributes: ['id', 'name', 'mobile'] }, // Vital for Admin
                // Include Masters if needed, but for list view usually not critical
            ],
            order: [['createdAt', 'DESC']]
        });
        return products;
    } catch (error) {
        throw error;
    }
};

const getCompletedPointsSalesCount = async (userId) => {
    try {
        const count = await Product.count({
            where: {
                userId: userId,
                status: 'sold',
                isPoints: true
            }
        });
        return count;
    } catch (error) {
        throw error;
    }
};

module.exports = {
    createProduct,
    getAllProducts,
    getProductById,
    updateProductStatus,
    getUserProducts,
    deleteProduct,
    getAdminProducts,
    getCompletedPointsSalesCount
};