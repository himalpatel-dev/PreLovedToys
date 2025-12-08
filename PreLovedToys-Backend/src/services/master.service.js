const db = require('../models');
const Category = db.Category;
const SubCategory = db.SubCategory;
const AgeGroup = db.AgeGroup;
const Color = db.Color;
const Gender = db.Gender;
const Material = db.Material;

// ==========================================
// 1. CATEGORY SERVICES
// ==========================================

const createCategory = async (data) => {
    const { name, image } = data;
    const categoryImage = image || `https://placehold.co/200x200?text=${name}`;
    return await Category.create({ name, image: categoryImage });
};

const getAllCategories = async () => {
    return await Category.findAll({
        order: [['name', 'ASC']],
    });
};

const getAllCategoriesWithSubCategories = async () => {
    return await Category.findAll({
        include: [{ model: SubCategory, as: 'subcategories' }]
    });
};

const getCategoryById = async (id) => {
    return await Category.findByPk(id, {
        include: [{ model: SubCategory, as: 'subcategories' }]
    });
};

const updateCategory = async (id, data) => {
    const category = await Category.findByPk(id);
    if (!category) return null;

    await category.update(data);
    return category;
};

const deleteCategory = async (id) => {
    const category = await Category.findByPk(id);
    if (!category) return null;

    await category.destroy();
    return category;
};

// ==========================================
// 2. SUB-CATEGORY SERVICES
// ==========================================

const createSubCategory = async (data) => {
    const { name, categoryId, image } = data;
    const subCategoryImage = image || `https://placehold.co/200x200?text=${name}`;
    return await SubCategory.create({
        name,
        categoryId,
        image: subCategoryImage,
        isActive: true
    });
};

const getAllSubCategories = async () => {
    return await SubCategory.findAll({ include: ['category'] });
};

const getSubCategoriesByCategoryId = async (categoryId) => {
    const whereClause = {};
    if (categoryId) {
        whereClause.categoryId = categoryId;
    }
    return await SubCategory.findAll({ where: whereClause });
};

const getSubCategoryById = async (id) => {
    return await SubCategory.findByPk(id, { include: ['category'] });
};

const updateSubCategory = async (id, data) => {
    const subCategory = await SubCategory.findByPk(id);
    if (!subCategory) return null;

    await subCategory.update(data);
    return subCategory;
};

const deleteSubCategory = async (id) => {
    const subCategory = await SubCategory.findByPk(id);
    if (!subCategory) return null;

    await subCategory.destroy();
    return subCategory;
};

// ==========================================
// 3. AGE GROUP SERVICES
// ==========================================

const createAgeGroup = async (data) => {
    return await AgeGroup.create(data);
};

const getAllAgeGroups = async () => {
    return await AgeGroup.findAll();
};

const getAgeGroupById = async (id) => {
    return await AgeGroup.findByPk(id);
};

const updateAgeGroup = async (id, data) => {
    const ageGroup = await AgeGroup.findByPk(id);
    if (!ageGroup) return null;

    await ageGroup.update(data);
    return ageGroup;
};

const deleteAgeGroup = async (id) => {
    const deleted = await AgeGroup.destroy({ where: { id } });
    return deleted > 0;
};

// ==========================================
// 4. COLOR SERVICES
// ==========================================

const createColor = async (data) => {
    return await Color.create(data);
};

const getAllColors = async () => {
    return await Color.findAll();
};

const getColorById = async (id) => {
    return await Color.findByPk(id);
};

const updateColor = async (id, data) => {
    const color = await Color.findByPk(id);
    if (!color) return null;

    await color.update(data);
    return color;
};

const deleteColor = async (id) => {
    const deleted = await Color.destroy({ where: { id } });
    return deleted > 0;
};

// ==========================================
// 5. GENDER SERVICES
// ==========================================

const createGender = async (data) => {
    return await Gender.create(data);
};

const getAllGenders = async () => {
    return await Gender.findAll();
};

const getGenderById = async (id) => {
    return await Gender.findByPk(id);
};

const updateGender = async (id, data) => {
    const gender = await Gender.findByPk(id);
    if (!gender) return null;

    await gender.update(data);
    return gender;
};

const deleteGender = async (id) => {
    const deleted = await Gender.destroy({ where: { id } });
    return deleted > 0;
};

// ==========================================
// 6. MATERIAL SERVICES
// ==========================================

const createMaterial = async (data) => {
    return await Material.create(data);
};

const getAllMaterials = async () => {
    return await Material.findAll();
};

const getMaterialById = async (id) => {
    return await Material.findByPk(id);
};

const updateMaterial = async (id, data) => {
    const material = await Material.findByPk(id);
    if (!material) return null;

    await material.update(data);
    return material;
};

const deleteMaterial = async (id) => {
    const deleted = await Material.destroy({ where: { id } });
    return deleted > 0;
};

module.exports = {
    // Category
    createCategory,
    getAllCategories,
    getAllCategoriesWithSubCategories,
    getCategoryById,
    updateCategory,
    deleteCategory,
    // SubCategory
    createSubCategory,
    getAllSubCategories,
    getSubCategoriesByCategoryId,
    getSubCategoryById,
    updateSubCategory,
    deleteSubCategory,
    // AgeGroup
    createAgeGroup,
    getAllAgeGroups,
    getAgeGroupById,
    updateAgeGroup,
    deleteAgeGroup,
    // Color
    createColor,
    getAllColors,
    getColorById,
    updateColor,
    deleteColor,
    // Gender
    createGender,
    getAllGenders,
    getGenderById,
    updateGender,
    deleteGender,
    // Material
    createMaterial,
    getAllMaterials,
    getMaterialById,
    updateMaterial,
    deleteMaterial
};
