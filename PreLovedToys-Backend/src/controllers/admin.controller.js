const adminService = require('../services/admin.service');

/**
 * Wraps a service call: sends its result as JSON, sends AppError messages with their
 * status, and hides unexpected errors behind a generic message (they are logged instead).
 */
const handle = (fn) => async (req, res) => {
    try {
        res.status(200).json(await fn(req));
    } catch (err) {
        if (err.status && err.status < 500) {
            return res.status(err.status).json({ message: err.message, code: err.code });
        }
        console.error('[admin]', err);
        res.status(500).json({ message: 'Something went wrong. Please try again.' });
    }
};

module.exports = {
    getDashboard: handle((req) => adminService.getDashboard(req.query)),

    listProducts: handle((req) => adminService.listProducts(req.query)),
    updateProduct: handle((req) => adminService.updateProduct(req.params.id, req.body)),
    deleteProduct: handle((req) => adminService.deleteProduct(req.params.id)),
    addProductImage: handle((req) => adminService.addProductImage(req.params.id, req.body)),
    removeProductImage: handle((req) => adminService.removeProductImage(req.params.id, req.params.imageId)),
    reorderProductImages: handle((req) => adminService.reorderProductImages(req.params.id, req.body)),

    listOrders: handle((req) => adminService.listOrders(req.query)),
    setOrderStatus: handle((req) => adminService.setOrderStatus(req.params.id, req.body)),

    listUsers: handle((req) => adminService.listUsers(req.query)),
    getUserDetail: handle((req) => adminService.getUserDetail(req.params.id)),

    listWallets: handle((req) => adminService.listWallets(req.query)),
    getWallet: handle((req) => adminService.getWallet(req.params.userId, req.query)),
    adjustWallet: handle((req) => adminService.adjustWallet(req.params.userId, req.body, req.admin)),

    listCategories: handle(() => adminService.listCategories()),
    setCategoryVisibility: handle((req) => adminService.setCategoryVisibility(req.params.id, req.body)),
    setSubCategoryVisibility: handle((req) => adminService.setSubCategoryVisibility(req.params.id, req.body)),

    getSettings: handle(() => adminService.getSettings()),
    updateSettings: handle((req) => adminService.updateSettings(req.body)),
};
