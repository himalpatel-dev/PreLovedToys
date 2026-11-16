/**
 * Category and subcategory images that ship with the backend (files in uploads/catalog,
 * listed by name in src/data/catalog-images.json).
 *
 * Images are stored in the DB as "/uploads/catalog/<file>". The Flutter app and the admin
 * portal turn that into a full URL by prefixing the server address.
 */
const mapping = require('../data/catalog-images.json');

/** Image path for a category name, or null if none is bundled. */
function categoryImage(categoryName) {
    return mapping.categories[categoryName] || null;
}

/** Image path for a subcategory (looked up under its parent category), or null. */
function subCategoryImage(categoryName, subCategoryName) {
    return (mapping.subcategories[categoryName] || {})[subCategoryName] || null;
}

/**
 * True when an existing image value is only a stand-in and may be replaced:
 * empty, a placeholder service URL, a path to an image bundled in the Flutter app,
 * or an earlier image from this bundled set (uploads/catalog).
 * Images uploaded by an admin (other "/uploads/..." paths or real URLs) are kept.
 */
function isReplaceableImage(image) {
    if (!image) return true;
    if (/placehold\.co|via\.placeholder\.com/i.test(image)) return true;
    if (/^\/?assets\//.test(image)) return true;
    if (image.startsWith('/uploads/catalog/')) return true;
    return false;
}

module.exports = { categoryImage, subCategoryImage, isReplaceableImage };
