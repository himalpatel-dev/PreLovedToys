const db = require('../models');
const Category = db.Category;
const SubCategory = db.SubCategory;
const Product = db.Product;
const AgeGroup = db.AgeGroup;
const Color = db.Color;
const Gender = db.Gender;
const Material = db.Material;

// ==========================================
// 1. CATEGORY CRUD
// ==========================================

const createCategory = async (req, res) => {
    try {
        let { name, image } = req.body;
        if (!name) return res.status(400).json({ message: "Name is required" });

        if (!image) {
            image = `https://placehold.co/200x200?text=${name}`;
        }

        const category = await Category.create({ name, image });
        res.status(201).json(category);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllCategories = async (req, res) => {
    try {
        const categories = await Category.findAll({
            include: [{
                model: SubCategory,
                as: 'subcategories',
                include: [{ model: Product, as: 'products', attributes: ['id'], required: false }],
                required: false
            }]
        });
        res.status(200).json(categories);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getCategoryById = async (req, res) => {
    try {
        const category = await Category.findByPk(req.params.id, {
            include: [{ model: SubCategory, as: 'subcategories' }]
        });
        if (!category) return res.status(404).json({ message: "Category not found" });
        res.status(200).json(category);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateCategory = async (req, res) => {
    try {
        const { name, image, isActive } = req.body;
        const category = await Category.findByPk(req.params.id);
        if (!category) return res.status(404).json({ message: "Category not found" });

        await category.update({ name, image, isActive });
        res.status(200).json({ message: "Category updated", category });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteCategory = async (req, res) => {
    try {
        const category = await Category.findByPk(req.params.id);
        if (!category) return res.status(404).json({ message: "Category not found" });

        await category.destroy();
        res.status(200).json({ message: "Category deleted" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// ==========================================
// 2. SUB-CATEGORY CRUD
// ==========================================

const createSubCategory = async (req, res) => {
    try {
        let { name, categoryId, image } = req.body;
        if (!image) {
            image = `https://placehold.co/200x200?text=${name}`;
        }

        const sub = await SubCategory.create({ name, categoryId, image, isActive: true });
        res.status(201).json(sub);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllSubCategories = async (req, res) => {
    try {
        const data = await SubCategory.findAll({ include: ['category'] });
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getSubCategoryById = async (req, res) => {
    try {
        const sub = await SubCategory.findByPk(req.params.id, { include: ['category'] });
        if (!sub) return res.status(404).json({ message: "SubCategory not found" });
        res.status(200).json(sub);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateSubCategory = async (req, res) => {
    try {
        const { name, categoryId, isActive, image } = req.body;
        const sub = await SubCategory.findByPk(req.params.id);
        if (!sub) return res.status(404).json({ message: "SubCategory not found" });

        await sub.update({ name, categoryId, isActive, image });
        res.status(200).json({ message: "SubCategory updated", sub });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteSubCategory = async (req, res) => {
    try {
        const sub = await SubCategory.findByPk(req.params.id);
        if (!sub) return res.status(404).json({ message: "SubCategory not found" });

        await sub.destroy();
        res.status(200).json({ message: "SubCategory deleted" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// ==========================================
// 3. AGE GROUP CRUD
// ==========================================

const createAgeGroup = async (req, res) => {
    try {
        const item = await AgeGroup.create(req.body);
        res.status(201).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllAgeGroups = async (req, res) => {
    try {
        const data = await AgeGroup.findAll();
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAgeGroupById = async (req, res) => {
    try {
        const item = await AgeGroup.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateAgeGroup = async (req, res) => {
    try {
        const item = await AgeGroup.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        await item.update(req.body);
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteAgeGroup = async (req, res) => {
    try {
        await AgeGroup.destroy({ where: { id: req.params.id } });
        res.status(200).json({ message: "Deleted" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// ==========================================
// 4. COLOR CRUD
// ==========================================

const createColor = async (req, res) => {
    try {
        const item = await Color.create(req.body);
        res.status(201).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllColors = async (req, res) => {
    try {
        const data = await Color.findAll();
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getColorById = async (req, res) => {
    try {
        const item = await Color.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateColor = async (req, res) => {
    try {
        const item = await Color.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        await item.update(req.body);
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteColor = async (req, res) => {
    try {
        await Color.destroy({ where: { id: req.params.id } });
        res.status(200).json({ message: "Deleted" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// ==========================================
// 5. GENDER CRUD
// ==========================================

const createGender = async (req, res) => {
    try {
        const item = await Gender.create(req.body);
        res.status(201).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllGenders = async (req, res) => {
    try {
        const data = await Gender.findAll();
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getGenderById = async (req, res) => {
    try {
        const item = await Gender.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateGender = async (req, res) => {
    try {
        const item = await Gender.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        await item.update(req.body);
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteGender = async (req, res) => {
    try {
        await Gender.destroy({ where: { id: req.params.id } });
        res.status(200).json({ message: "Deleted" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// ==========================================
// 6. MATERIAL CRUD
// ==========================================

const createMaterial = async (req, res) => {
    try {
        const item = await Material.create(req.body);
        res.status(201).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllMaterials = async (req, res) => {
    try {
        const data = await Material.findAll();
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getMaterialById = async (req, res) => {
    try {
        const item = await Material.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateMaterial = async (req, res) => {
    try {
        const item = await Material.findByPk(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        await item.update(req.body);
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteMaterial = async (req, res) => {
    try {
        await Material.destroy({ where: { id: req.params.id } });
        res.status(200).json({ message: "Deleted" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    // Category
    createCategory, getAllCategories, getCategoryById, updateCategory, deleteCategory,
    // SubCategory
    createSubCategory, getAllSubCategories, getSubCategoryById, updateSubCategory, deleteSubCategory,
    // AgeGroup
    createAgeGroup, getAllAgeGroups, getAgeGroupById, updateAgeGroup, deleteAgeGroup,
    // Color
    createColor, getAllColors, getColorById, updateColor, deleteColor,
    // Gender
    createGender, getAllGenders, getGenderById, updateGender, deleteGender,
    // Material
    createMaterial, getAllMaterials, getMaterialById, updateMaterial, deleteMaterial
};