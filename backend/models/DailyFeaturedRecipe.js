const mongoose = require('mongoose');

const dailyFeaturedRecipeSchema = new mongoose.Schema(
  {
    dateKey: { type: String, required: true, unique: true, index: true }, // Format: YYYY-MM-DD
    recipes: [
      {
        id: { type: String, required: true },
        title: { type: String, required: true },
        source: { type: String, default: 'USDA_HealthyMeals' },
        category: { type: String, default: 'High Protein' },
        calories: { type: Number, default: 350 },
        protein: { type: Number, default: 30 },
        carbs: { type: Number, default: 35 },
        fats: { type: Number, default: 12 },
        fiber: { type: Number, default: 5 },
        prepTimeMinutes: { type: Number, default: 20 },
        cookTimeMinutes: { type: Number, default: 25 },
        servings: { type: Number, default: 2 },
        difficulty: { type: String, default: 'Easy' },
        imageUrl: { type: String, default: '' },
        instructions: [{ type: String }],
        ingredients: [{ type: String }],
        tags: [{ type: String }],
        tips: { type: String, default: '' },
      },
    ],
  },
  {
    timestamps: true,
    collection: 'daily_featured_recipes',
  }
);

module.exports = mongoose.model('DailyFeaturedRecipe', dailyFeaturedRecipeSchema);
