/**
 * Sets the bundled catalog images (uploads/catalog) on the categories and subcategories
 * that already exist in the database. Only image columns change; no rows are added or removed.
 *
 * A row is updated only when its current image is a stand-in (empty, placehold.co, or an
 * "/assets/..." path from the Flutter app). Pass --force to also replace other images,
 * such as ones an admin uploaded.
 *
 * Usage:
 *   node migrations/apply_catalog_images.js            # apply
 *   node migrations/apply_catalog_images.js --dry-run  # only report what would change
 *   node migrations/apply_catalog_images.js --force    # replace every image that has a match
 */
const path = require('path');
const fs = require('fs');
const db = require('../src/models');
const { categoryImage, subCategoryImage, isReplaceableImage } = require('../src/utils/catalog-images');

const dryRun = process.argv.includes('--dry-run');
const force = process.argv.includes('--force');
const uploadsDir = path.join(__dirname, '..', 'uploads');

function fileExists(imagePath) {
    return fs.existsSync(path.join(uploadsDir, imagePath.replace(/^\/uploads\//, '')));
}

async function run() {
    const stats = { updated: 0, alreadySet: 0, keptCustom: 0, noImage: [], missingFile: [] };

    const categories = await db.Category.findAll({
        include: [{ model: db.SubCategory, as: 'subcategories' }],
        order: [['name', 'ASC']],
    });

    // All updates commit together or not at all.
    await db.sequelize.transaction(async (transaction) => {
        const apply = async (row, label, image) => {
            if (!image) return stats.noImage.push(label);
            if (!fileExists(image)) return stats.missingFile.push(`${label} -> ${image}`);
            if (row.image === image) return stats.alreadySet++;
            if (!force && !isReplaceableImage(row.image)) return stats.keptCustom++;
            if (!dryRun) await row.update({ image }, { transaction });
            stats.updated++;
        };

        for (const category of categories) {
            await apply(category, category.name, categoryImage(category.name));
            for (const sub of category.subcategories) {
                await apply(sub, `${category.name} > ${sub.name}`, subCategoryImage(category.name, sub.name));
            }
        }
    });

    console.log(`${dryRun ? '[dry run] would update' : 'Updated'}: ${stats.updated}`);
    console.log(`Already set: ${stats.alreadySet}`);
    console.log(`Kept (custom image, use --force to replace): ${stats.keptCustom}`);
    if (stats.noImage.length) console.log(`No bundled image for: ${stats.noImage.join(', ')}`);
    if (stats.missingFile.length) console.log(`Missing files:\n  ${stats.missingFile.join('\n  ')}`);
}

run()
    .catch((err) => {
        console.error('Failed:', err);
        process.exitCode = 1;
    })
    .finally(() => db.sequelize.close());
