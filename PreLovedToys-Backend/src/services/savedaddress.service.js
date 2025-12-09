const db = require('../models');
const SavedAddress = db.SavedAddress;

// 1. Create a new saved address
const createAddress = async (userId, addressData) => {
    try {
        // If this address is set as default, unset all other default addresses for this user
        if (addressData.is_default) {
            await SavedAddress.update(
                { is_default: false },
                { where: { userId, is_default: true } }
            );
        }

        const newAddress = await SavedAddress.create({
            userId,
            receiver_name: addressData.receiver_name,
            phone_number: addressData.phone_number,
            address_line1: addressData.address_line1,
            address_line2: addressData.address_line2 || null,
            city: addressData.city,
            state: addressData.state,
            country: addressData.country,
            pincode: addressData.pincode,
            address_type: addressData.address_type,
            is_default: addressData.is_default || false
        });

        return newAddress;
    } catch (error) {
        throw error;
    }
};

// 2. Get all saved addresses for a user
const getUserAddresses = async (userId) => {
    try {
        const addresses = await SavedAddress.findAll({
            where: { userId },
            order: [
                ['createdAt', 'DESC']
            ]
        });

        return addresses;
    } catch (error) {
        throw error;
    }
};

// 3. Get a single address by ID
const getAddressById = async (addressId, userId) => {
    try {
        const address = await SavedAddress.findOne({
            where: { id: addressId, userId }
        });

        if (!address) {
            throw new Error('Address not found');
        }

        return address;
    } catch (error) {
        throw error;
    }
};

// 4. Update an address
const updateAddress = async (addressId, userId, addressData) => {
    try {
        const address = await SavedAddress.findOne({
            where: { id: addressId, userId }
        });

        if (!address) {
            throw new Error('Address not found');
        }

        // If setting this as default, unset other defaults
        if (addressData.is_default && !address.is_default) {
            await SavedAddress.update(
                { is_default: false },
                { where: { userId, is_default: true } }
            );
        }

        // Update the address
        await address.update({
            receiver_name: addressData.receiver_name || address.receiver_name,
            phone_number: addressData.phone_number || address.phone_number,
            address_line1: addressData.address_line1 || address.address_line1,
            address_line2: addressData.address_line2 !== undefined ? addressData.address_line2 : address.address_line2,
            city: addressData.city || address.city,
            state: addressData.state || address.state,
            country: addressData.country || address.country,
            pincode: addressData.pincode || address.pincode,
            address_type: addressData.address_type || address.address_type,
            is_default: addressData.is_default !== undefined ? addressData.is_default : address.is_default
        });

        return address;
    } catch (error) {
        throw error;
    }
};

// 5. Delete an address
const deleteAddress = async (addressId, userId) => {
    try {
        const address = await SavedAddress.findOne({
            where: { id: addressId, userId }
        });

        if (!address) {
            throw new Error('Address not found');
        }

        await address.destroy();
        return { message: 'Address deleted successfully' };
    } catch (error) {
        throw error;
    }
};

// 6. Set an address as default
const setDefaultAddress = async (addressId, userId) => {
    try {
        const address = await SavedAddress.findOne({
            where: { id: addressId, userId }
        });

        if (!address) {
            throw new Error('Address not found');
        }

        // Unset all other defaults
        await SavedAddress.update(
            { is_default: false },
            { where: { userId, is_default: true } }
        );

        // Set this as default
        await address.update({ is_default: true });

        return address;
    } catch (error) {
        throw error;
    }
};

// 7. Get default address
const getDefaultAddress = async (userId) => {
    try {
        const address = await SavedAddress.findOne({
            where: { userId, is_default: true }
        });

        return address;
    } catch (error) {
        throw error;
    }
};

module.exports = {
    createAddress,
    getUserAddresses,
    getAddressById,
    updateAddress,
    deleteAddress,
    setDefaultAddress,
    getDefaultAddress
};
