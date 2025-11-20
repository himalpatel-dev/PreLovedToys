const db = require('./src/models');

// ---------------------------
// Category data
// ---------------------------
const categories = [
    { name: "Dolls & Accessories", image: "https://placehold.co/200x200/E91E63/white?text=Dolls" },
    { name: "Vehicles", image: "https://placehold.co/200x200/3357FF/white?text=Vehicles" },
    { name: "Soft Toys", image: "https://placehold.co/200x200/F39C12/white?text=Soft+Toys" },
    { name: "Gun", image: "https://placehold.co/200x200/C0392B/white?text=Gun" },
    { name: "Puzzles", image: "https://placehold.co/200x200/8E44AD/white?text=Puzzles" },
    { name: "Block Games", image: "https://placehold.co/200x200/2ECC71/white?text=Block+Games" },
    { name: "Art & Craft", image: "https://placehold.co/200x200/F39C12/white?text=Art+%26+Craft" },
    { name: "Board Games", image: "https://placehold.co/200x200/3357FF/white?text=Board+Games" },
    { name: "Educational Toys & Games", image: "https://placehold.co/200x200/28B463/white?text=Educational+Toys" },
    { name: "Sports", image: "https://placehold.co/200x200/FF8F00/white?text=Sports" },
    { name: "Activity Games & Toys", image: "https://placehold.co/200x200/1ABC9C/white?text=Activity+Games" },
    { name: "Musical Toys", image: "https://placehold.co/200x200/D35400/white?text=Musical+Toys" },
    { name: "Others", image: "https://placehold.co/200x200/7F8C8D/white?text=Others" },
    { name: "Push & Pull Toys", image: "https://placehold.co/200x200/E91E63/white?text=Push+%26+Pull+Toys" },
    { name: "Riders", image: "https://placehold.co/200x200/34495E/white?text=Riders" },
    { name: "Electronic Toys", image: "https://placehold.co/200x200/9B59B6/white?text=Electronic+Toys" }
];

// ---------------------------
// Subcategory data
// ---------------------------
const subCategoryData = [
    { categoryName: "Dolls & Accessories", subs: ["Fashion Dolls", "Dollhouses", "Baby Dolls", "Doll Clothes", "Playsets"] },
    { categoryName: "Vehicles", subs: ["Remote Control Cars", "Die-Cast Models", "Trains & Tracks", "Drones", "Trucks"] },
    { categoryName: "Soft Toys", subs: ["Teddy Bears", "Animals", "Cartoon Characters", "Interactive Plush"] },
    { categoryName: "Gun", subs: ["Bullet", "Air Pressure", "Musical"] },
    { categoryName: "Puzzles", subs: ["Fruit & Vegetable", "Transport", "Animal & Bird", "Educational", "Magnetic", "Story", "Fun Puzzle Games"] },
    { categoryName: "Block Games", subs: ["Activity Blocks", "Building Blocks", "Magnetic Blocks", "Stick Blocks", "Bullet Blocks"] },
    { categoryName: "Art & Craft", subs: ["Jewellery Making Games", "Clay Toys", "Scratching/ Colouring Games", "Quilling Games", "Others"] },
    { categoryName: "Board Games", subs: ["Educational Board", "Chess", "Ludo & Snakes", "Wooden Board Games", "Carrom", "Business", "Monopoly", "Sequence", "Word Games", "D-Dart", "Housie", "Chinese Checker", "Tic Tac Toe", "Adventure Games", "Combos"] },
    { categoryName: "Educational Toys & Games", subs: ["Mechanical Games", "Magnetic Shapes & Colours", "Globes", "Brainvita", "Flash Cards", "Abacus", "Educational Shapes", "Preschool Toys", "Memory Games", "Educational Numbers & Alphabets", "3D Books", "Science Games"] },
    { categoryName: "Sports", subs: ["Basket Ball", "Cricket Sets", "Bowling Games", "Bow & Arrow", "Golf Set", "Table Tennis", "Hockey", "Challenge Sports"] },
    { categoryName: "Activity Games & Toys", subs: ["Flying Disk", "Bladders", "Play Tent House", "Ringtoss", "Hoopla Ring", "Play Gym", "Spiral Fun", "Hopscotch", "Ball Pool", "Spinner", "Rolling Fun", "Teddy Ring", "Magic Game", "Cycle", "Other Activity Game", "Target & Aim Games", "Rings Toys"] },
    { categoryName: "Musical Toys", subs: ["Rattles", "Roly Poly", "Musical Drum", "Xylophone", "Jhoomer", "Musical Animals", "Musical Vehicles", "Musical Instrument Toys", "Musical Teddy"] },
    { categoryName: "Others", subs: ["Kitchen Set", "Dolls", "Piggy Bank", "Cup Stackers", "Cube", "Almirah", "Carry Cot", "Doctor Set", "Pen Stand", "Beauty Set", "Sofa", "Activity Toys", "Warrior Fighter Set", "Teether", "Baby Suitcase"] },
    { categoryName: "Push & Pull Toys", subs: ["Cars", "Trucks & Dumpers", "Bike", "Boats & Ships", "Plane", "Pull Along Toys", "Push & Go Toys", "Animals", "Trains", "Cranes", "Bus", "Friction Toys", "Fire Brigade", "Auto Rikshaw", "Jeep", "Ambulance", "Helicopter", "Tractor"] },
    { categoryName: "Riders", subs: ["Ride On Cars", "Tricycle", "Rockers"] },
    { categoryName: "Electronic Toys", subs: ["Electronic Gun", "Electronic Educational Toys", "Electronic Musical Toys", "Electronic Activity Toys", "Other Electronic Toys"] }
];

// ---------------------------
// Master tables: AgeGroups, Colors, Genders, Materials
// ---------------------------
const ageGroups = [
    { name: "0-12 Months" },
    { name: "1-2 Years" },
    { name: "3-5 Years" },
    { name: "6-9 Years" },
    { name: "10-12 Years" },
    { name: "12+ Years" }
];

const colors = [
    { name: "Red", hexCode: "#FF0000" },
    { name: "Blue", hexCode: "#0000FF" },
    { name: "Green", hexCode: "#008000" },
    { name: "Yellow", hexCode: "#FFFF00" },
    { name: "Black", hexCode: "#000000" },
    { name: "White", hexCode: "#FFFFFF" },
    { name: "Pink", hexCode: "#FFC0CB" },
    { name: "Purple", hexCode: "#800080" },
    { name: "Orange", hexCode: "#FFA500" },
    { name: "Brown", hexCode: "#A52A2A" },
    { name: "Grey", hexCode: "#808080" },
    { name: "Multi-color", hexCode: "linear-gradient(to right, red,orange,yellow,green,blue,indigo,violet)" }
];

const genders = [
    { name: "Boys" },
    { name: "Girls" },
    { name: "Unisex" }
];

const materials = [
    { name: "Plastic" },
    { name: "Cardboard" },
    { name: "Paper" },
    { name: "Rubber" },
    { name: "Natural materials" },
    { name: "Acrylic" },
    { name: "Cotton" },
    { name: "Magnet" },
    { name: "Wooden" },
    { name: "Fabric" },
    { name: "Metal" },
    { name: "Woolen" },
    { name: "Other" }
];

// ---------------------------
// Seeder functions
// ---------------------------
async function seedMasters() {

    console.log('🌱 Seeding Master Tables...');

    for (const cat of categories) {
        await db.Category.findOrCreate({ where: { name: cat.name }, defaults: { image: cat.image } });
    }
    console.log('✅ Categories seeded.');

    for (const item of subCategoryData) {
        const category = await db.Category.findOne({ where: { name: item.categoryName } });
        if (!category) {
            console.log(` ⚠️ Skipped: Category '${item.categoryName}' not found.`);
            continue;
        }


        const categorycolor = category.image.match(/200x200\/([^/]+)\//)?.[1] || 'CCCCCC';
        for (const subName of item.subs) {
            await db.SubCategory.findOrCreate({
                where: { name: subName, categoryId: category.id },
                // Auto-generate subcategory image using category's color code
                defaults: { isActive: true, image: `https://placehold.co/200x200/${categorycolor}/white?text=${encodeURIComponent(subName)}` }
            });
        }
        console.log(` > Added subs for ${item.categoryName}`);
    }


    console.log('✅ Subcategories seeded.');

    for (const item of ageGroups) {
        await db.AgeGroup.findOrCreate({ where: { name: item.name }, defaults: item });
    }
    console.log('  - Age Groups done');

    for (const item of colors) {
        await db.Color.findOrCreate({ where: { name: item.name }, defaults: item });
    }
    console.log('  - Colors done');

    for (const item of genders) {
        await db.Gender.findOrCreate({ where: { name: item.name }, defaults: item });
    }
    console.log('  - Genders done');

    for (const item of materials) {
        // Use upsert so the explicit id is respected when your Material model has defined primary key as id
        await db.Material.upsert(item);
    }
    console.log('  - Materials done');

    console.log('✅ Master tables seeded.');
}

// ---------------------------
// Runner
// ---------------------------
async function seedAll() {
    try {
        // If you want to run everything in a transaction, and your DB supports it across all tables, wrap here.
        await seedMasters();

        console.log('🎉 All seeding finished successfully.');
    } catch (err) {
        console.error('❌ Seeding failed:', err);
    } finally {
        // Close DB connection (Sequelize) if available
        if (db.sequelize && typeof db.sequelize.close === 'function') {
            await db.sequelize.close();
        }
        process.exit(0);
    }
}

// If run directly (node seedMaster.js), execute seedAll
if (require.main === module) {
    seedAll();
}

module.exports = { seedAll, seedMasters };
