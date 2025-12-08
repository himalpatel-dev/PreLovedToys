const masterService = require('../services/master.service');

// ==========================================
// 1. CATEGORY CRUD
// ==========================================

const createCategory = async (req, res) => {
    try {
        const { name, image } = req.body;
        if (!name) return res.status(400).json({ message: "Name is required" });

        const category = await masterService.createCategory({ name, image });
        res.status(201).json(category);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllCategories = async (req, res) => {
    try {
        const categories = await masterService.getAllCategories();
        res.status(200).json(categories);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllCategoriesWithSubCategories = async (req, res) => {
    try {
        const categories = await masterService.getAllCategoriesWithSubCategories();
        res.status(200).json(categories);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getCategoryById = async (req, res) => {
    try {
        const category = await masterService.getCategoryById(req.params.id);
        if (!category) return res.status(404).json({ message: "Category not found" });
        res.status(200).json(category);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateCategory = async (req, res) => {
    try {
        const { name, image, isActive } = req.body;
        const category = await masterService.updateCategory(req.params.id, { name, image, isActive });
        if (!category) return res.status(404).json({ message: "Category not found" });

        res.status(200).json({ message: "Category updated", category });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteCategory = async (req, res) => {
    try {
        const category = await masterService.deleteCategory(req.params.id);
        if (!category) return res.status(404).json({ message: "Category not found" });

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
        const { name, categoryId, image } = req.body;
        const sub = await masterService.createSubCategory({ name, categoryId, image });
        res.status(201).json(sub);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllSubCategories = async (req, res) => {
    try {
        const data = await masterService.getAllSubCategories();
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getSubCategoryById = async (req, res) => {
    try {
        const sub = await masterService.getSubCategoryById(req.params.id);
        if (!sub) return res.status(404).json({ message: "SubCategory not found" });
        res.status(200).json(sub);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateSubCategory = async (req, res) => {
    try {
        const { name, categoryId, isActive, image } = req.body;
        const sub = await masterService.updateSubCategory(req.params.id, { name, categoryId, isActive, image });
        if (!sub) return res.status(404).json({ message: "SubCategory not found" });

        res.status(200).json({ message: "SubCategory updated", sub });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteSubCategory = async (req, res) => {
    try {
        const sub = await masterService.deleteSubCategory(req.params.id);
        if (!sub) return res.status(404).json({ message: "SubCategory not found" });

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
        const item = await masterService.createAgeGroup(req.body);
        res.status(201).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllAgeGroups = async (req, res) => {
    try {
        const data = await masterService.getAllAgeGroups();
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAgeGroupById = async (req, res) => {
    try {
        const item = await masterService.getAgeGroupById(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateAgeGroup = async (req, res) => {
    try {
        const item = await masterService.updateAgeGroup(req.params.id, req.body);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteAgeGroup = async (req, res) => {
    try {
        const deleted = await masterService.deleteAgeGroup(req.params.id);
        if (!deleted) return res.status(404).json({ message: "Not found" });
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
        const item = await masterService.createColor(req.body);
        res.status(201).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllColors = async (req, res) => {
    try {
        const data = await masterService.getAllColors();
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getColorById = async (req, res) => {
    try {
        const item = await masterService.getColorById(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateColor = async (req, res) => {
    try {
        const item = await masterService.updateColor(req.params.id, req.body);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteColor = async (req, res) => {
    try {
        const deleted = await masterService.deleteColor(req.params.id);
        if (!deleted) return res.status(404).json({ message: "Not found" });
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
        const item = await masterService.createGender(req.body);
        res.status(201).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllGenders = async (req, res) => {
    try {
        const data = await masterService.getAllGenders();
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getGenderById = async (req, res) => {
    try {
        const item = await masterService.getGenderById(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateGender = async (req, res) => {
    try {
        const item = await masterService.updateGender(req.params.id, req.body);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteGender = async (req, res) => {
    try {
        const deleted = await masterService.deleteGender(req.params.id);
        if (!deleted) return res.status(404).json({ message: "Not found" });
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
        const item = await masterService.createMaterial(req.body);
        res.status(201).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getAllMaterials = async (req, res) => {
    try {
        const data = await masterService.getAllMaterials();
        res.status(200).json(data);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const getMaterialById = async (req, res) => {
    try {
        const item = await masterService.getMaterialById(req.params.id);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const updateMaterial = async (req, res) => {
    try {
        const item = await masterService.updateMaterial(req.params.id, req.body);
        if (!item) return res.status(404).json({ message: "Not found" });
        res.status(200).json(item);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

const deleteMaterial = async (req, res) => {
    try {
        const deleted = await masterService.deleteMaterial(req.params.id);
        if (!deleted) return res.status(404).json({ message: "Not found" });
        res.status(200).json({ message: "Deleted" });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    // Category
    createCategory, getAllCategories, getAllCategoriesWithSubCategories, getCategoryById, updateCategory, deleteCategory,
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