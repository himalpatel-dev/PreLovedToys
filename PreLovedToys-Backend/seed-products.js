const db = require('./src/models');

// ---------------------------
// Raw Product Data (Human Readable)
// ---------------------------
const rawProducts = [
    {
        title: "High Speed RC Racing Car",
        description: "Red remote control car with rechargeable battery. Runs very fast on flat surfaces.",
        price: 100,
        condition: "Like New",
        category: "Vehicles",
        subCategory: "Remote Control Cars",
        ageGroup: "6-9 Years",
        gender: "Boys",
        color: "Red",
        material: "Plastic",
        image: "https://placehold.co/600x400/FF0000/white?text=RC+Car"
    },
    {
        title: "Barbie Fashion Doll Set",
        description: "Includes doll with 3 extra dresses and shoes. Box is slightly damaged but doll is new.",
        price: 80,
        condition: "Good",
        category: "Dolls & Accessories",
        subCategory: "Fashion Dolls",
        ageGroup: "3-5 Years",
        gender: "Girls",
        color: "Pink",
        material: "Plastic",
        image: "https://placehold.co/600x400/FFC0CB/white?text=Barbie+Doll"
    },
    {
        title: "Wooden Chess Board",
        description: "Classic wooden chess set. Magnetic pieces. Great for brain development.",
        price: 40,
        condition: "Like New",
        category: "Board Games",
        subCategory: "Chess",
        ageGroup: "12+ Years",
        gender: "Unisex",
        color: "Brown",
        material: "Wooden",
        image: "https://placehold.co/600x400/A52A2A/white?text=Chess+Board"
    },
    {
        title: "Giant Soft Teddy Bear",
        description: "3 feet tall teddy bear. Very soft fabric. washable.",
        price: 110,
        condition: "New",
        category: "Soft Toys",
        subCategory: "Teddy Bears",
        ageGroup: "1-2 Years",
        gender: "Unisex",
        color: "Brown",
        material: "Fabric",
        image: "https://placehold.co/600x400/8E44AD/white?text=Teddy+Bear"
    },
    {
        title: "Cricket Kit (Size 5)",
        description: "Plastic cricket bat with ball and wickets. Safe for indoor and outdoor play.",
        price: 70,
        condition: "Fair",
        category: "Sports",
        subCategory: "Cricket Sets",
        ageGroup: "10-12 Years",
        gender: "Boys",
        color: "Blue",
        material: "Plastic",
        image: "https://placehold.co/600x400/0000FF/white?text=Cricket+Set"
    },
    {
        title: "Building Blocks Bucket",
        description: "50 pieces of colorful building blocks. Helps in creativity.",
        price: 40,
        condition: "Good",
        category: "Block Games",
        subCategory: "Building Blocks",
        ageGroup: "3-5 Years",
        gender: "Unisex",
        color: "Multi-color",
        material: "Plastic",
        image: "https://placehold.co/600x400/FFFF00/black?text=Blocks"
    },
    {
        title: "Musical Drum Set",
        description: "Small drum for toddlers with sticks. Makes pleasant sounds.",
        price: 50,
        condition: "Like New",
        category: "Musical Toys",
        subCategory: "Musical Drum",
        ageGroup: "1-2 Years",
        gender: "Unisex",
        color: "Orange",
        material: "Plastic",
        image: "https://placehold.co/600x400/FFA500/black?text=Drum"
    },
    {
        title: "Toy Gun with Foam Bullets",
        description: "Safe toy gun with soft foam bullets. Comes with 10 bullets.",
        price: 60,
        condition: "Good",
        category: "Gun",
        subCategory: "Bullet",
        ageGroup: "6-9 Years",
        gender: "Boys",
        color: "Black",
        material: "Plastic",
        image: "https://placehold.co/600x400/000000/white?text=Toy+Gun"
    },
    {
        title: "Kids Tricycle",
        description: "Sturdy tricycle with back support. Good for learning to ride.",
        price: 80,
        condition: "Good",
        category: "Riders",
        subCategory: "Tricycle",
        ageGroup: "1-2 Years",
        gender: "Unisex",
        color: "Red",
        material: "Metal",
        image: "https://placehold.co/600x400/FF0000/white?text=Tricycle"
    },
    {
        title: "Clay Modelling Kit",
        description: "12 colors of non-toxic clay with moulds.",
        price: 100,
        condition: "New",
        category: "Art & Craft",
        subCategory: "Clay Toys",
        ageGroup: "3-5 Years",
        gender: "Unisex",
        color: "Multi-color",
        material: "Other",
        image: "https://placehold.co/600x400/1ABC9C/white?text=Clay+Kit"
    }
];

// ---------------------------
// Seeder Function
// ---------------------------
async function seedProducts() {
    try {
        console.log('🌱 Seeding Products based on new Master Data...');

        // 1️⃣ Ensure we have a demo ADMIN seller
        let adminSeller = await db.User.findOne({
            where: { role: 'admin' }
        });
    
        if (!adminSeller) {
            console.log('Creating demo ADMIN seller...');
            adminSeller = await db.User.create({
                mobile: '9999999999',
                name: 'Demo Admin',
                role: 'admin'
            });
            
            // Create wallet for admin seller
            await db.Wallet.create({
                userId: adminSeller.id,
                balance: '300' // Initial welcome bonus
            });
            
            // Create initial transaction record
            await db.WalletTransaction.create({
                walletId: adminSeller.id,
                type: 'credit',
                amount: '300',
                balanceAfter: '300',
                description: 'Welcome bonus - Account creation',
                refUserId: null
            });
            
            console.log('✅ Wallet created for Admin seller with 300 points');
        }
    
        // 2️⃣ Ensure we have a demo USER seller
        let userSeller = await db.User.findOne({
            where: { mobile: '9727376727' }
        });
    
        if (!userSeller) {
            console.log('Creating demo USER seller...');
            userSeller = await db.User.create({
                mobile: '9727376727',  
                role: 'user'
            });
            
            // Create wallet for user seller
            await db.Wallet.create({
                userId: userSeller.id,
                balance: '300' // Initial welcome bonus
            });
            
            // Create initial transaction record
            await db.WalletTransaction.create({
                walletId: userSeller.id,
                type: 'credit',
                amount: '300',
                balanceAfter: '300',
                description: 'Welcome bonus - Account creation',
                refUserId: null
            });
            
            console.log('✅ Wallet created for User seller with 300 points');
        }

        for (const p of rawProducts) {
            // 2. LOOKUP ALL IDs DYNAMICALLY
            const cat = await db.Category.findOne({ where: { name: p.category } });
            const sub = await db.SubCategory.findOne({ where: { name: p.subCategory } });
            const age = await db.AgeGroup.findOne({ where: { name: p.ageGroup } });
            const gen = await db.Gender.findOne({ where: { name: p.gender } });
            const col = await db.Color.findOne({ where: { name: p.color } });
            const mat = await db.Material.findOne({ where: { name: p.material } });

            // 3. Validate Data Found
            if (cat && sub && age && gen && col && mat) {

                // 4. Create Product
                const newProduct = await db.Product.create({
                    title: p.title,
                    description: p.description,
                    price: p.price,
                    condition: p.condition,
                    status: 'active',
                    userId: userSeller.id,

                    // Foreign Keys
                    categoryId: cat.id,
                    subCategoryId: sub.id,
                    ageGroupId: age.id,
                    genderId: gen.id,
                    colorId: col.id,
                    materialId: mat.id
                });

                // 5. Add Image
                await db.ProductImage.create({
                    productId: newProduct.id,
                    imageUrl: p.image,
                    isPrimary: true
                });

                console.log(`✅ Added: ${p.title}`);
            } else {
                console.log(`❌ FAILED to add: ${p.title}`);
                if (!cat) console.log(`   Missing Category: ${p.category}`);
                if (!sub) console.log(`   Missing SubCategory: ${p.subCategory}`);
                if (!age) console.log(`   Missing AgeGroup: ${p.ageGroup}`);
                if (!gen) console.log(`   Missing Gender: ${p.gender}`);
                if (!col) console.log(`   Missing Color: ${p.color}`);
                if (!mat) console.log(`   Missing Material: ${p.material}`);
            }
        }

        console.log('🎉 Product Seeding Completed!');

    } catch (error) {
        console.error('❌ Error seeding products:', error);
    } finally {
        // Close connection
        if (db.sequelize && typeof db.sequelize.close === 'function') {
            await db.sequelize.close();
        }
    }
}

// Run
seedProducts();