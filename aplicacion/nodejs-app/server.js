const express = require('express');
const dotenv = require('dotenv');
const catalogRoutes = require('./routes/catalog');
const cartRoutes = require('./routes/cart');
const customerRoutes = require('./routes/customer');
const inventoryRoutes = require('./routes/inventory');

dotenv.config();

const app = express();

app.use(express.json());

app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'ok',
        service: 'nodejs-obligatorio'
    });
});

app.use('/catalog', catalogRoutes);
app.use('/cart', cartRoutes);
app.use('/customer', customerRoutes);
app.use('/inventory', inventoryRoutes);

const PORT = process.env.APP_PORT || 3000;

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
