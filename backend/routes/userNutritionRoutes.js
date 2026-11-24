const express = require('express');
const router = express.Router();
const userNutritionController = require('../controllers/userNutritionController');

// User Daily Nutrition Routes
router.get('/today', userNutritionController.getTodayNutrition);
router.get('/today/:uid', userNutritionController.getTodayNutrition);
router.get('/date', userNutritionController.getTodayNutrition);
router.get('/date/:uid/:date', userNutritionController.getTodayNutrition);
router.get('/history', userNutritionController.getNutritionHistory);
router.get('/history/:uid', userNutritionController.getNutritionHistory);
router.post('/log-meal', userNutritionController.logMeal);
router.delete('/meal/:uid/:mealId', userNutritionController.deleteMeal);
router.post('/water', userNutritionController.updateWater);
router.get('/suggestions', userNutritionController.getMealSuggestions);

module.exports = router;
