const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cartController');

router.get('/:userId', cartController.getCart);
router.post('/:userId', cartController.addToCart);
router.delete('/:userId/:productId', cartController.removeFromCart);

module.exports = router;