const jwt = require('jsonwebtoken');
const db = require('../models');

/**
 * Requires a valid "Authorization: Bearer <token>" header.
 *
 * Also loads the account on every request, so a user who is banned (isActive = false) or
 * deleted is locked out immediately, even though their token has not expired. req.user.role
 * is taken from the database, not the token, so role changes apply at once too.
 */
const verifyToken = async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Access denied. No token provided or invalid format.' });
    }

    const token = authHeader.split(' ')[1];

    let decoded;
    try {
        decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (ex) {
        // Token is expired, invalid, or corrupted
        return res.status(401).json({ message: 'Invalid token or session expired.' });
    }

    try {
        const user = await db.User.findByPk(decoded.id, { attributes: ['id', 'role', 'isActive'] });
        if (!user) {
            return res.status(401).json({ message: 'Account not found. Please sign in again.' });
        }
        if (user.isActive === false) {
            return res.status(403).json({
                message: 'This account has been blocked. Please contact support.',
                code: 'ACCOUNT_BLOCKED'
            });
        }
        req.user = { ...decoded, id: user.id, role: user.role };
        next();
    } catch (err) {
        next(err);
    }
};

module.exports = verifyToken;
