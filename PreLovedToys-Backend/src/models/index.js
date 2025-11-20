const sequelize = require('../config/db.config');

// Import Models
const User = require('./user.model');
const Category = require('./category.model');
const Product = require('./product.model');
const ProductImage = require('./product_image.model');
const CartItem = require('./cart_item.model');
const Order = require('./order.model');
const OrderItem = require('./order_item.model');
const db = {};

db.sequelize = sequelize;
db.User = User;
db.Category = Category;
db.Product = Product;
db.ProductImage = ProductImage;
db.CartItem = CartItem;
db.Order = Order;
db.OrderItem = OrderItem;

// =========================================
// DEFINE RELATIONSHIPS
// =========================================

// 1. Category <-> Product
// A Category has many Products
db.Category.hasMany(db.Product, {
    foreignKey: 'categoryId',
    as: 'products'
});
// A Product belongs to a Category
db.Product.belongsTo(db.Category, {
    foreignKey: 'categoryId',
    as: 'category'
});

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

module.exports = db;