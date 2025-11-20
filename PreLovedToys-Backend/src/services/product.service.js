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
        const newProduct = await Product.create({
            title: data.title,
            description: data.description,
            price: data.price,
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
const getAllProducts = async (status = 'active') => {
    try {
        const products = await Product.findAll({
            where: { status: status },
            include: [
                { model: ProductImage, as: 'images', attributes: ['imageUrl', 'isPrimary'] },
                { model: Category, as: 'category', attributes: ['name'] },
                { model: SubCategory, as: 'subcategory', attributes: ['name'] },
                { model: User, as: 'seller', attributes: ['name'] },
                // INCLUDE NEW MASTERS
                { model: AgeGroup, as: 'ageGroup', attributes: ['name'] },
                { model: Color, as: 'color', attributes: ['name', 'hexCode'] },
                { model: Gender, as: 'gender', attributes: ['name'] },
                { model: Material, as: 'material', attributes: ['name'] }
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

module.exports = {
    createProduct,
    getAllProducts,
    getProductById,
    updateProductStatus,
    getUserProducts,
    deleteProduct
};