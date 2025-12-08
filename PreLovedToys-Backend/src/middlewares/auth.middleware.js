const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    // 1. Get token from header (typically looks like: 'Bearer <TOKEN>')
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ message: 'Access denied. No token provided or invalid format.' });
    }

    // Extract the actual token string
    const token = authHeader.split(' ')[1];

    try {
        // 2. Verify the token using the secret key
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // 3. Attach the decoded user info to the request object
        req.user = decoded;


        // Token is valid and role is admin, proceed to the next middleware/route handler
        next();
    } catch (ex) {
        // Token is expired, invalid, or corrupted
        res.status(401).json({ message: 'Invalid token or session expired.' });
    }
};

module.exports = verifyToken;