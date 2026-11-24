const mongoose = require('mongoose');

const loggedMealSchema = new mongoose.Schema({
  mealId: { type: String, required: true },
  mealType: {
    type: String,
    enum: ['breakfast', 'lunch', 'dinner', 'snack'],
    default: 'breakfast',
  },
  foodName: { type: String, required: true },
  source: { type: String, default: 'USDA' }, // 'USDA', 'Indian', 'OpenFoodFacts', 'Custom'
  category: { type: String, default: 'General' },
  calories: { type: Number, default: 0 },
  protein: { type: Number, default: 0 },
  carbs: { type: Number, default: 0 },
  fat: { type: Number, default: 0 },
  fiber: { type: Number, default: 0 },
  servingSize: { type: String, default: '1 serving (100g)' },
  quantity: { type: Number, default: 1 },
  time: { type: String, default: '' },
  iconType: { type: String, default: 'restaurant' },
  loggedAt: { type: Date, default: Date.now },
});

const userDailyNutritionSchema = new mongoose.Schema(
  {
    uid: { type: String, required: true, index: true },
    date: { type: String, required: true, index: true }, // Format: YYYY-MM-DD
    targetCalories: { type: Number, default: 2400 },
    targetProtein: { type: Number, default: 140 },
    targetCarbs: { type: Number, default: 220 },
    targetFat: { type: Number, default: 60 },
    consumedCalories: { type: Number, default: 0 },
    consumedProtein: { type: Number, default: 0 },
    consumedCarbs: { type: Number, default: 0 },
    consumedFat: { type: Number, default: 0 },
    consumedFiber: { type: Number, default: 0 },
    waterGlasses: { type: Number, default: 0 }, // Starts from 0
    waterTargetGlasses: { type: Number, default: 8 },
    waterMilliliters: { type: Number, default: 0 },
    meals: [loggedMealSchema],
  },
  {
    timestamps: true,
    collection: 'users_daily_nutrition',
  }
);

userDailyNutritionSchema.index({ uid: 1, date: 1 }, { unique: true });

module.exports = mongoose.model('UserDailyNutrition', userDailyNutritionSchema);
