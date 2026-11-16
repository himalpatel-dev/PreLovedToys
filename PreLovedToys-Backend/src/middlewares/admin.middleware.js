const db = require('../models');

/**
 * Allows the request only for an active admin. Use after verifyToken.
 *
 * The role is read from the database rather than trusted from the token, so an admin
 * who is demoted or banned loses access immediately instead of when the token expires.
 */
async function requireAdmin(req, res, next) {
    try {
        const user = req.user && await db.User.findByPk(req.user.id, {
            attributes: ['id', 'name', 'role', 'isActive'],
        });
        if (!user || user.role !== 'admin' || user.isActive === false) {
            return res.status(403).json({ message: 'Admin access required.' });
        }
        req.admin = user;
        next();
    } catch (err) {
        next(err);
    }
}

module.exports = requireAdmin;
