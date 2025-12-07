const db = require('../models');
const Category = db.Category;
const SubCategory = db.SubCategory;
const AgeGroup = db.AgeGroup;
const Color = db.Color;
const Gender = db.Gender;
const Material = db.Material;

// Get All Categories
const getAllCategories = async () => {
    return await Category.findAll();
};

// Get SubCategories by Category ID
const getSubCategories = async (categoryId) => {
    const whereClause = {};
    if (categoryId) {
        whereClause.categoryId = categoryId;
    }
    return await SubCategory.findAll({ where: whereClause });
};

// Get All Age Groups
const getAllAgeGroups = async () => {
    return await AgeGroup.findAll();
};

// Get All Colors
const getAllColors = async () => {
    return await Color.findAll();
};

// Get All Genders
const getAllGenders = async () => {
    return await Gender.findAll();
};

// Get All Materials
const getAllMaterials = async () => {
    return await Material.findAll();
};

module.exports = {
    getAllCategories,
    getSubCategories,
    getAllAgeGroups,
    getAllColors,
    getAllGenders,
    getAllMaterials
};
