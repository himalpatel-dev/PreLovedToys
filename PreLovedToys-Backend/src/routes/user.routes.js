const express = require('express');
const router = express.Router();
const userController = require('../controllers/user.controller');
const verifyToken = require('../middlewares/auth.middleware');

// Protect these routes! Only logged-in Admins should access.
// (Assuming verifyToken checks for valid user, you might want an 'isAdmin' middleware later)
router.get('/', verifyToken, userController.getAllUsers);
router.put('/:id/status', verifyToken, userController.toggleUserStatus);
// Allow authenticated user to update their own profile
router.put('/profile', verifyToken, userController.updateProfile);
// Get authenticated user's profile
router.get('/profile', verifyToken, userController.getProfile);

module.exports = router;