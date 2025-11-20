const db = require('../models');
const Category = db.Category;
const SubCategory = db.SubCategory;
// 1. Create Category (Admin only)
const createCategory = async (req, res) => {
    try {
        const { name, image } = req.body;

        if (!name) {
            return res.status(400).json({ message: "Category name is required" });
        }

        const category = await Category.create({ name, image });

        res.status(201).json({
            message: "Category created successfully",
            category
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// 2. Get All Categories (For Home Page)
const getAllCategories = async (req, res) => {
    try {
        const categories = await Category.findAll({
            where: { isActive: true },
            include: [
                {
                    model: SubCategory,
                    as: 'subcategories', // Must match alias in index.js
                    attributes: ['id', 'name']
                }
            ]
        });
        res.status(200).json(categories);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createCategory,
    getAllCategories
};