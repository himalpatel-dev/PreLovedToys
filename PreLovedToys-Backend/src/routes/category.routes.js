const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/category.controller');

// POST /api/categories (Create)
router.post('/', categoryController.createCategory);

// GET /api/categories (List)
router.get('/', categoryController.getAllCategories);

module.exports = router;