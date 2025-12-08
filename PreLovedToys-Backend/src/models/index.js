const sequelize = require('../config/db.config');

// Import Models
const User = require('./user.model');
const Category = require('./category.model');
const Product = require('./product.model');
const ProductImage = require('./product_image.model');
const CartItem = require('./cart_item.model');
const Order = require('./order.model');
const OrderItem = require('./order_item.model');
const SubCategory = require('./subcategory.model');
const AgeGroup = require('./age_group.model');
const Color = require('./color.model');
const Gender = require('./gender.model');
const Material = require('./material.model');
const Wallet = require('./wallet.model');
const WalletTransaction = require('./wallet_transaction.model');
const Favorite = require('./favorite.model');
const SavedAddress = require('./savedaddress.model');

const db = {};

db.sequelize = sequelize;
db.User = User;
db.Category = Category;
db.Product = Product;
db.ProductImage = ProductImage;
db.CartItem = CartItem;
db.Order = Order;
db.OrderItem = OrderItem;
db.SubCategory = SubCategory;
db.AgeGroup = AgeGroup;
db.Color = Color;
db.Gender = Gender;
db.Material = Material;
db.Wallet = Wallet;
db.WalletTransaction = WalletTransaction;
db.Favorite = Favorite;
db.SavedAddress = SavedAddress;

// =========================================
// DEFINE RELATIONSHIPS
// =========================================

// 1. Category <-> SubCategory (One Category has many SubCategories)
db.Category.hasMany(db.SubCategory, { foreignKey: 'categoryId', as: 'subcategories' });
db.SubCategory.belongsTo(db.Category, { foreignKey: 'categoryId', as: 'category' });

// 2. Category <-> Product
db.Category.hasMany(db.Product, { foreignKey: 'categoryId', as: 'products' });
db.Product.belongsTo(db.Category, { foreignKey: 'categoryId', as: 'category' });

// 3. SubCategory <-> Product (One SubCategory has many Products)
db.SubCategory.hasMany(db.Product, { foreignKey: 'subCategoryId', as: 'products' });
db.Product.belongsTo(db.SubCategory, { foreignKey: 'subCategoryId', as: 'subcategory' });

// Age Group
db.AgeGroup.hasMany(db.Product, { foreignKey: 'ageGroupId' });
db.Product.belongsTo(db.AgeGroup, { foreignKey: 'ageGroupId', as: 'ageGroup' });

// Color
db.Color.hasMany(db.Product, { foreignKey: 'colorId' });
db.Product.belongsTo(db.Color, { foreignKey: 'colorId', as: 'color' });

// Gender
db.Gender.hasMany(db.Product, { foreignKey: 'genderId' });
db.Product.belongsTo(db.Gender, { foreignKey: 'genderId', as: 'gender' });

// Material
db.Material.hasMany(db.Product, { foreignKey: 'materialId' });
db.Product.belongsTo(db.Material, { foreignKey: 'materialId', as: 'material' });

// 2. User (Seller) <-> Product
// A User (Seller) creates many Products
db.User.hasMany(db.Product, {
    foreignKey: 'userId',
    as: 'products'
});
// A Product belongs to a User (Seller)
db.Product.belongsTo(db.User, {
    foreignKey: 'userId',
    as: 'seller'
});

// Product <-> ProductImage (New Relationship)
db.Product.hasMany(db.ProductImage, {
    foreignKey: 'productId',
    as: 'images' // We will access it as product.images
});
db.ProductImage.belongsTo(db.Product, {
    foreignKey: 'productId',
    as: 'product'
});

// User <-> CartItem
db.User.hasMany(db.CartItem, { foreignKey: 'userId', as: 'cartItems' });
db.CartItem.belongsTo(db.User, { foreignKey: 'userId', as: 'user' });

// Product <-> CartItem
db.Product.hasMany(db.CartItem, { foreignKey: 'productId', as: 'cartInclusions' });
db.CartItem.belongsTo(db.Product, { foreignKey: 'productId', as: 'product' });

// User <-> Order
db.User.hasMany(db.Order, { foreignKey: 'userId', as: 'orders' });
db.Order.belongsTo(db.User, { foreignKey: 'userId', as: 'user' });

// Order <-> OrderItem
db.Order.hasMany(db.OrderItem, { foreignKey: 'orderId', as: 'items' });
db.OrderItem.belongsTo(db.Order, { foreignKey: 'orderId', as: 'order' });

// Product <-> OrderItem (So we know which product was bought)
db.Product.hasMany(db.OrderItem, { foreignKey: 'productId' });
db.OrderItem.belongsTo(db.Product, { foreignKey: 'productId', as: 'product' });

// Wallet relationships
// Each User has one Wallet
db.User.hasOne(db.Wallet, { foreignKey: 'userId', as: 'wallet' });
db.Wallet.belongsTo(db.User, { foreignKey: 'userId', as: 'user' });

// Wallet -> Transactions
db.Wallet.hasMany(db.WalletTransaction, { foreignKey: 'walletId', as: 'transactions' });
db.WalletTransaction.belongsTo(db.Wallet, { foreignKey: 'walletId', as: 'wallet' });

// Favorite relationships
// User <-> Favorite (A user can have many favorites)
db.User.hasMany(db.Favorite, { foreignKey: 'userId', as: 'favorites' });
db.Favorite.belongsTo(db.User, { foreignKey: 'userId', as: 'user' });

// Product <-> Favorite (A product can be favorited by many users)
db.Product.hasMany(db.Favorite, { foreignKey: 'productId', as: 'favoritedBy' });
db.Favorite.belongsTo(db.Product, { foreignKey: 'productId', as: 'product' });

// SavedAddress relationships
// User <-> SavedAddress (A user can have many saved addresses)
db.User.hasMany(db.SavedAddress, { foreignKey: 'userId', as: 'savedAddresses' });
db.SavedAddress.belongsTo(db.User, { foreignKey: 'userId', as: 'user' });

module.exports = db;