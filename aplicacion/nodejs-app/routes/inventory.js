const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventoryController');

router.get('/', inventoryController.getInventory);
router.post('/', inventoryController.addProduct);
router.put('/:id', inventoryController.updateProduct);
router.delete('/:id', inventoryController.deleteProduct);

module.exports = router;