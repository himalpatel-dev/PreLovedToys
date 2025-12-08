const savedAddressService = require('../services/savedaddress.service');

// Create a new address
const createAddress = async (req, res) => {
    try {
        const userId = req.user.id; // From auth middleware
        const address = await savedAddressService.createAddress(userId, req.body);
        res.status(201).json({ message: 'Address created successfully', address });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get all addresses for the authenticated user
const getMyAddresses = async (req, res) => {
    try {
        const userId = req.user.id;
        const addresses = await savedAddressService.getUserAddresses(userId);
        res.status(200).json(addresses);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get a single address by ID
const getAddressById = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const address = await savedAddressService.getAddressById(id, userId);
        res.status(200).json(address);
    } catch (error) {
        if (error.message === 'Address not found') {
            return res.status(404).json({ message: error.message });
        }
        res.status(500).json({ message: error.message });
    }
};

// Update an address
const updateAddress = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const address = await savedAddressService.updateAddress(id, userId, req.body);
        res.status(200).json({ message: 'Address updated successfully', address });
    } catch (error) {
        if (error.message === 'Address not found') {
            return res.status(404).json({ message: error.message });
        }
        res.status(500).json({ message: error.message });
    }
};

// Delete an address
const deleteAddress = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const result = await savedAddressService.deleteAddress(id, userId);
        res.status(200).json(result);
    } catch (error) {
        if (error.message === 'Address not found') {
            return res.status(404).json({ message: error.message });
        }
        res.status(500).json({ message: error.message });
    }
};

// Set an address as default
const setDefaultAddress = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params;
        const address = await savedAddressService.setDefaultAddress(id, userId);
        res.status(200).json({ message: 'Default address updated', address });
    } catch (error) {
        if (error.message === 'Address not found') {
            return res.status(404).json({ message: error.message });
        }
        res.status(500).json({ message: error.message });
    }
};

// Get default address
const getDefaultAddress = async (req, res) => {
    try {
        const userId = req.user.id;
        const address = await savedAddressService.getDefaultAddress(userId);

        if (!address) {
            return res.status(404).json({ message: 'No default address found' });
        }

        res.status(200).json(address);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createAddress,
    getMyAddresses,
    getAddressById,
    updateAddress,
    deleteAddress,
    setDefaultAddress,
    getDefaultAddress
};
