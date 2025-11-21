const express = require('express');
const router = express.Router();
const masterController = require('../controllers/master.controller');

// ================== CATEGORY ROUTES ==================
router.post('/categories', masterController.createCategory);
router.get('/categories', masterController.getAllCategories);
router.get('/categories/:id', masterController.getCategoryById);
router.put('/categories/:id', masterController.updateCategory);
router.delete('/categories/:id', masterController.deleteCategory);

// ================== SUBCATEGORY ROUTES ==================
router.post('/subcategories', masterController.createSubCategory);
router.get('/subcategories', masterController.getAllSubCategories);
router.get('/subcategories/:id', masterController.getSubCategoryById);
router.put('/subcategories/:id', masterController.updateSubCategory);
router.delete('/subcategories/:id', masterController.deleteSubCategory);

// ================== AGE GROUP ROUTES ==================
router.post('/age-groups', masterController.createAgeGroup);
router.get('/age-groups', masterController.getAllAgeGroups);
router.get('/age-groups/:id', masterController.getAgeGroupById);
router.put('/age-groups/:id', masterController.updateAgeGroup);
router.delete('/age-groups/:id', masterController.deleteAgeGroup);

// ================== COLOR ROUTES ==================
router.post('/colors', masterController.createColor);
router.get('/colors', masterController.getAllColors);
router.get('/colors/:id', masterController.getColorById);
router.put('/colors/:id', masterController.updateColor);
router.delete('/colors/:id', masterController.deleteColor);

// ================== GENDER ROUTES ==================
router.post('/genders', masterController.createGender);
router.get('/genders', masterController.getAllGenders);
router.get('/genders/:id', masterController.getGenderById);
router.put('/genders/:id', masterController.updateGender);
router.delete('/genders/:id', masterController.deleteGender);

// ================== MATERIAL ROUTES ==================
router.post('/materials', masterController.createMaterial);
router.get('/materials', masterController.getAllMaterials);
router.get('/materials/:id', masterController.getMaterialById);
router.put('/materials/:id', masterController.updateMaterial);
router.delete('/materials/:id', masterController.deleteMaterial);

module.exports = router;