const mongoose = require('mongoose');

const recipeSchema = new mongoose.Schema(
  {
    id: { type: String, required: true, unique: true, index: true },
    title: { type: String, required: true, trim: true },
    name: { type: String, trim: true },
    cuisine: {
      type: String,
      default: 'Indian Fitness',
    },
    dietaryType: {
      type: String,
      default: 'Vegetarian',
      enum: ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Eggitarian'],
    },
    category: {
      type: String,
      default: 'High Protein',
      enum: [
        'All Recipes',
        'Breakfast',
        'Main Course',
        'High Protein',
        'Curries & Dals',
        'Rice & Biryani',
        'Healthy Snacks',
        'Pre/Post-Workout',
        'Soups & Salads',
        'General',
      ],
    },
    prepTimeMinutes: { type: Number, default: 15 },
    cookTimeMinutes: { type: Number, default: 20 },
    totalTime: { type: String, default: '35 mins' },
    servings: { type: Number, default: 2 },
    difficulty: {
      type: String,
      default: 'Easy',
      enum: ['Easy', 'Intermediate', 'Advanced'],
    },
    rating: { type: Number, default: 4.8 },
    calories: { type: Number, required: true, default: 350 },
    protein: { type: Number, required: true, default: 25 },
    carbs: { type: Number, required: true, default: 30 },
    fat: { type: Number, required: true, default: 10 },
    fiber: { type: Number, default: 5 },
    imageUrl: { type: String, default: '' },
    thumbnailUrl: { type: String, default: '' },
    videoUrl: { type: String, default: '' },
    youtubeUrl: { type: String, default: '' },
    ingredients: [
      {
        name: { type: String, required: true },
        quantity: { type: String, default: '' },
        unit: { type: String, default: '' },
      },
    ],
    ingredientList: [{ type: String }],
    steps: [{ type: String }],
    instructions: { type: String, default: '' },
    chefTips: { type: String, default: '' },
    tags: [{ type: String }],
    source: { type: String, default: 'IndianCurated' },
    isVerified: { type: Boolean, default: true },
    isActive: { type: Boolean, default: true },
    sortOrder: { type: Number, default: 0 },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Recipe', recipeSchema);
