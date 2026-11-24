const express = require('express');
const router = express.Router();
const foodController = require('../controllers/foodController');

// Live Nutritional Facts Search APIs
router.get('/search-ifct', foodController.searchIfctFoods);
router.get('/search-usda', foodController.searchUsdaFoods);
router.get('/search-off', foodController.searchOpenFoodFacts);
router.get('/search-live', foodController.searchUnifiedLiveFoods);

// Standard CRUD
router.get('/', foodController.getAllFoods);
router.get('/:id', foodController.getFoodById);
router.post('/', foodController.createFood);
router.put('/:id', foodController.updateFood);
router.delete('/:id', foodController.deleteFood);

module.exports = router;
