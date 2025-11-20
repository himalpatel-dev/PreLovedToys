const express = require('express');
const router = express.Router();
const upload = require('../utils/file-upload');

// POST /api/upload
// 'image' is the key name the frontend must use
router.post('/', upload.single('image'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ message: "No file uploaded" });
        }

        // Create the public URL
        // Example: http://localhost:3000/uploads/12345-filename.jpg
        const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;

        res.status(200).json({
            message: "Upload successful",
            imageUrl: imageUrl
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;