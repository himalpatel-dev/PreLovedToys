const db = require('../models');
const AppError = require('../utils/app-error');
const Product = db.Product;
const Category = db.Category;
const SubCategory = db.SubCategory;
const AgeGroup = db.AgeGroup;
const Color = db.Color;
const Gender = db.Gender;
const Material = db.Material;

/**
 * Refuses to delete a catalogue entry that is still in use, so listings never end up
 * pointing at nothing. `uses` is a list of [count, singular, plural?] entries.
 */
function assertUnused(name, uses, hint) {
    const parts = uses
        .filter(([n]) => n > 0)
        .map(([n, one, many]) => `${n} ${n === 1 ? one : many || `${one}s`}`);
    if (parts.length) {
        throw new AppError(`Can't delete “${name}”: it is still used by ${parts.join(' and ')}. ${hint}`, 409);
    }
}

// ==========================================
// 1. CATEGORY SERVICES
// (The app only sees active entries; the admin portal lists all via /api/admin.)
// ==========================================

const createCategory = async (data) => {
    const { name, image } = data;
    const categoryImage = image || `https://placehold.co/200x200?text=${name}`;
    return await Category.create({ name, image: categoryImage });
};

const getAllCategories = async () => {
    return await Category.findAll({
        where: { isActive: true },
        order: [['name', 'ASC']],
    });
};

const getAllCategoriesWithSubCategories = async () => {
    return await Category.findAll({
        where: { isActive: true },
        include: [{ model: SubCategory, as: 'subcategories', where: { isActive: true }, required: false }],
        order: [['name', 'ASC'], [{ model: SubCategory, as: 'subcategories' }, 'name', 'ASC']],
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

    const [subs, listings] = await Promise.all([
        SubCategory.count({ where: { categoryId: category.id } }),
        Product.count({ where: { categoryId: category.id } }),
    ]);
    assertUnused(category.name, [[subs, 'sub-category', 'sub-categories'], [listings, 'listing']],
        'Hide it instead, or move or delete those first.');

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
    return await SubCategory.findAll({
        where: { isActive: true },
        // required: only subs whose parent category is visible too
        include: [{ model: Category, as: 'category', where: { isActive: true }, required: true }],
        order: [['name', 'ASC']],
    });
};

const getSubCategoriesByCategoryId = async (categoryId) => {
    const whereClause = { isActive: true };
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

    const listings = await Product.count({ where: { subCategoryId: subCategory.id } });
    assertUnused(subCategory.name, [[listings, 'listing']], 'Hide it instead, or move those listings first.');

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

/** Simple masters (age group, color, gender, material) can't be deleted while listings use them. */
async function assertMasterUnused(Model, field, id) {
    const row = await Model.findByPk(id, { attributes: ['id', 'name'] });
    if (!row) return;
    const listings = await Product.count({ where: { [field]: row.id } });
    assertUnused(row.name, [[listings, 'listing']], 'Change those listings first.');
}

const deleteAgeGroup = async (id) => {
    await assertMasterUnused(AgeGroup, 'ageGroupId', id);
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
    await assertMasterUnused(Color, 'colorId', id);
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
    await assertMasterUnused(Gender, 'genderId', id);
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
    await assertMasterUnused(Material, 'materialId', id);
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
