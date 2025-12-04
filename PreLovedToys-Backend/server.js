require('dotenv').config();
const express = require('express');
const cors = require('cors');
const db = require('./src/models');
const path = require('path');
const uploadRoutes = require('./src/routes/upload.routes');
const app = express();

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// 1. IMPORT ROUTES
const authRoutes = require('./src/routes/auth.routes');
const masterRoutes = require('./src/routes/master.routes');
const productRoutes = require('./src/routes/product.routes');
const cartRoutes = require('./src/routes/cart.routes');
const orderRoutes = require('./src/routes/order.routes');
const userRoutes = require('./src/routes/user.routes');
const statsRoutes = require('./src/routes/stats.routes');
const walletRoutes = require('./src/routes/wallet.routes');

// 2. USE ROUTES
app.use('/api/auth', authRoutes);
app.use('/api/master', masterRoutes);
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/upload', uploadRoutes);
app.use('/api/users', userRoutes);
app.use('/api/stats', statsRoutes);
app.use('/api/wallet', walletRoutes);

// Test Route
app.get('/', (req, res) => {
    res.json({ message: 'PreLovedToys API is running!' });
});

const PORT = process.env.PORT || 4000;

db.sequelize.sync({ alter: true })
    .then(() => {
        console.log('✅ Database & Tables synced successfully.');
        app.listen(PORT, () => {
            console.log(`🚀 Server is running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error('❌ Failed to sync database:', err);
    });