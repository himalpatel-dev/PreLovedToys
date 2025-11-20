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

        // CHANGE: Return only the filename, not the full URL
        res.status(200).json({
            message: "Upload successful",
            filename: req.file.filename // <--- JUST THE FILENAME
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
});

module.exports = router;