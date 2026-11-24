const mongoose = require('mongoose');

const foodItemSchema = new mongoose.Schema(
  {
    id: { type: String, required: true, unique: true, index: true },
    barcode: { type: String, default: '', index: true },
    name: { type: String, required: true, trim: true },
    brand: { type: String, default: '', trim: true },
    category: {
      type: String,
      default: 'General',
      enum: [
        'All Foods',
        'Fruits',
        'Poultry & Meat',
        'Grains & Oats',
        'Dairy & Eggs',
        'Nuts & Seeds',
        'Seafood',
        'Vegetables & Greens',
        'Supplements & Shakes',
        'Healthy Snacks',
        'Beverages',
        'General',
      ],
    },
    servingSize: { type: String, default: '100g' },
    servingUnit: { type: String, default: 'g' },
    servingWeightGrams: { type: Number, default: 100 },
    calories: { type: Number, required: true, default: 0 },
    protein: { type: Number, required: true, default: 0 },
    carbs: { type: Number, required: true, default: 0 },
    fat: { type: Number, required: true, default: 0 },
    fiber: { type: Number, default: 0 },
    sugar: { type: Number, default: 0 },
    sodium: { type: Number, default: 0 }, // in mg
    potassium: { type: Number, default: 0 }, // in mg
    cholesterol: { type: Number, default: 0 }, // in mg
    saturatedFat: { type: Number, default: 0 },
    nutriscore: { type: String, enum: ['A', 'B', 'C', 'D', 'E', 'Unknown'], default: 'A' },
    novaGroup: { type: Number, min: 1, max: 4, default: 1 },
    imageUrl: { type: String, default: '' },
    thumbnailUrl: { type: String, default: '' },
    ingredients: [{ type: String }],
    ingredientText: { type: String, default: '' },
    allergens: [{ type: String }],
    vitamins: { type: String, default: '' },
    isVerified: { type: Boolean, default: true },
    source: { type: String, default: 'OpenFoodFacts' },
    isActive: { type: Boolean, default: true },
    sortOrder: { type: Number, default: 0 },
  },
  { timestamps: true }
);

module.exports = mongoose.model('FoodItem', foodItemSchema);
