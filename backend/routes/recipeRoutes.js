const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController');

// Live Multi-Source Recipe Search Routes
router.get('/daily-featured', recipeController.getDailyFeaturedRecipes);
router.get('/search-live', recipeController.searchLiveRecipes);
router.get('/search-indian', recipeController.searchIndianRecipesLive);
router.get('/search-usda', recipeController.searchUsdaRecipesLive);
router.get('/search-mealdb', recipeController.searchMealDbRecipesLive);

// Standard CRUD
router.get('/', recipeController.getAllRecipes);
router.get('/:id', recipeController.getRecipeById);
router.post('/', recipeController.createRecipe);
router.put('/:id', recipeController.updateRecipe);
router.delete('/:id', recipeController.deleteRecipe);

module.exports = router;
