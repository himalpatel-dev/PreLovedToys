const jwt = require('jsonwebtoken');

const verifyToken = (req, res, next) => {
    // 1. Get token directly from the custom header
    // We use 'x-access-token' which is a standard custom header name
    const token = req.headers['x-access-token'];

    if (!token) {
        return res.status(403).json({
            message: "No token provided! Add 'x-access-token' to headers."
        });
    }

    // 2. Verify token
    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ message: "Unauthorized! Invalid Token." });
        }

        // 3. Save user ID to request object
        req.user = decoded;
        next();
    });
};

module.exports = verifyToken;