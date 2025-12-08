const express = require('express');
const router = express.Router();
const savedAddressController = require('../controllers/savedaddress.controller');
const verifyToken = require('../middlewares/auth.middleware');

router.use(verifyToken); // Protect all routes

// 1. Specific routes first
router.get('/my-addresses', savedAddressController.getMyAddresses); // Get all user addresses
router.get('/default', savedAddressController.getDefaultAddress); // Get default address
router.post('/', savedAddressController.createAddress); // Create new address

// 2. Variable ID routes
router.get('/:id', savedAddressController.getAddressById); // Get single address
router.put('/:id', savedAddressController.updateAddress); // Update address
router.delete('/:id', savedAddressController.deleteAddress); // Delete address
router.put('/:id/set-default', savedAddressController.setDefaultAddress); // Set as default

module.exports = router;
