const UserDailyNutrition = require('../models/UserDailyNutrition');
const usdaHealthyRecipes = require('../data/usdaHealthyRecipes');

// Helper to get local date key YYYY-MM-DD
function getTodayDateKey() {
  const now = new Date();
  const year = now.getFullYear();
  const month = String(now.getMonth() + 1).padStart(2, '0');
  const day = String(now.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

// 1. Get today's or specific date's nutrition (starts from 0 if not existing)
exports.getTodayNutrition = async (req, res) => {
  try {
    const uid = req.params.uid || req.query.uid;
    const dateKey = req.params.date || req.query.date || getTodayDateKey();

    if (!uid) {
      return res.status(400).json({ success: false, message: 'User ID is required' });
    }

    let record = await UserDailyNutrition.findOne({ uid, date: dateKey });

    if (!record) {
      // Create new record for today starting strictly from 0
      record = new UserDailyNutrition({
        uid,
        date: dateKey,
        targetCalories: 2400,
        targetProtein: 140,
        targetCarbs: 220,
        targetFat: 60,
        consumedCalories: 0,
        consumedProtein: 0,
        consumedCarbs: 0,
        consumedFat: 0,
        consumedFiber: 0,
        waterGlasses: 0,
        waterTargetGlasses: 8,
        waterMilliliters: 0,
        meals: [],
      });
      await record.save();
    }

    res.status(200).json({
      success: true,
      nutrition: record,
    });
  } catch (error) {
    console.error('Error in getTodayNutrition:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 2. Log a meal into today's nutrition
exports.logMeal = async (req, res) => {
  try {
    const {
      uid,
      date = getTodayDateKey(),
      mealType = 'breakfast',
      foodName,
      source = 'USDA',
      category = 'General',
      calories = 0,
      protein = 0,
      carbs = 0,
      fat = 0,
      fiber = 0,
      servingSize = '1 serving',
      quantity = 1,
      iconType = 'restaurant',
    } = req.body;

    if (!uid || !foodName) {
      return res.status(400).json({ success: false, message: 'uid and foodName are required' });
    }

    let record = await UserDailyNutrition.findOne({ uid, date });

    if (!record) {
      record = new UserDailyNutrition({
        uid,
        date,
        consumedCalories: 0,
        consumedProtein: 0,
        consumedCarbs: 0,
        consumedFat: 0,
        consumedFiber: 0,
        waterGlasses: 0,
        meals: [],
      });
    }

    const now = new Date();
    const timeStr = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    const mealId = `meal_${Date.now()}_${Math.random().toString(36).substr(2, 6)}`;

    const qty = Number(quantity) > 0 ? Number(quantity) : 1;
    const addCalories = Math.round(Number(calories) * qty);
    const addProtein = parseFloat((Number(protein) * qty).toFixed(1));
    const addCarbs = parseFloat((Number(carbs) * qty).toFixed(1));
    const addFat = parseFloat((Number(fat) * qty).toFixed(1));
    const addFiber = parseFloat((Number(fiber) * qty).toFixed(1));

    const newMeal = {
      mealId,
      mealType,
      foodName,
      source,
      category,
      calories: addCalories,
      protein: addProtein,
      carbs: addCarbs,
      fat: addFat,
      fiber: addFiber,
      servingSize,
      quantity: qty,
      time: timeStr,
      iconType,
      loggedAt: new Date(),
    };

    record.meals.push(newMeal);

    // Increment consumed macros
    record.consumedCalories = Math.max(0, record.consumedCalories + addCalories);
    record.consumedProtein = parseFloat((record.consumedProtein + addProtein).toFixed(1));
    record.consumedCarbs = parseFloat((record.consumedCarbs + addCarbs).toFixed(1));
    record.consumedFat = parseFloat((record.consumedFat + addFat).toFixed(1));
    record.consumedFiber = parseFloat((record.consumedFiber + addFiber).toFixed(1));

    await record.save();

    // Socket.io real-time broadcast if socket is connected
    if (req.io) {
      req.io.to(`user_${uid}`).emit('user_nutrition_updated', {
        uid,
        date,
        nutrition: record,
      });
    }

    res.status(200).json({
      success: true,
      message: 'Meal logged successfully',
      nutrition: record,
      loggedMeal: newMeal,
    });
  } catch (error) {
    console.error('Error in logMeal:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 3. Delete a logged meal
exports.deleteMeal = async (req, res) => {
  try {
    const { uid, mealId } = req.params;
    const date = req.query.date || getTodayDateKey();

    if (!uid || !mealId) {
      return res.status(400).json({ success: false, message: 'uid and mealId are required' });
    }

    const record = await UserDailyNutrition.findOne({ uid, date });
    if (!record) {
      return res.status(404).json({ success: false, message: 'Nutrition record not found' });
    }

    const mealToDelete = record.meals.find((m) => m.mealId === mealId);
    if (!mealToDelete) {
      return res.status(404).json({ success: false, message: 'Meal not found' });
    }

    // Deduct macros
    record.consumedCalories = Math.max(0, record.consumedCalories - (mealToDelete.calories || 0));
    record.consumedProtein = Math.max(0, parseFloat((record.consumedProtein - (mealToDelete.protein || 0)).toFixed(1)));
    record.consumedCarbs = Math.max(0, parseFloat((record.consumedCarbs - (mealToDelete.carbs || 0)).toFixed(1)));
    record.consumedFat = Math.max(0, parseFloat((record.consumedFat - (mealToDelete.fat || 0)).toFixed(1)));
    record.consumedFiber = Math.max(0, parseFloat((record.consumedFiber - (mealToDelete.fiber || 0)).toFixed(1)));

    record.meals = record.meals.filter((m) => m.mealId !== mealId);

    await record.save();

    if (req.io) {
      req.io.to(`user_${uid}`).emit('user_nutrition_updated', {
        uid,
        date,
        nutrition: record,
      });
    }

    res.status(200).json({
      success: true,
      message: 'Meal deleted successfully',
      nutrition: record,
    });
  } catch (error) {
    console.error('Error in deleteMeal:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 4. Update hydration / water intake
exports.updateWater = async (req, res) => {
  try {
    const { uid, date = getTodayDateKey(), delta = 1, glasses } = req.body;

    if (!uid) {
      return res.status(400).json({ success: false, message: 'uid is required' });
    }

    let record = await UserDailyNutrition.findOne({ uid, date });

    if (!record) {
      record = new UserDailyNutrition({
        uid,
        date,
        consumedCalories: 0,
        waterGlasses: 0,
      });
    }

    if (glasses !== undefined) {
      record.waterGlasses = Math.max(0, Number(glasses));
    } else {
      record.waterGlasses = Math.max(0, record.waterGlasses + Number(delta));
    }
    record.waterMilliliters = record.waterGlasses * 250; // 250ml per glass

    await record.save();

    if (req.io) {
      req.io.to(`user_${uid}`).emit('user_nutrition_updated', {
        uid,
        date,
        nutrition: record,
      });
    }

    res.status(200).json({
      success: true,
      waterGlasses: record.waterGlasses,
      waterMilliliters: record.waterMilliliters,
      nutrition: record,
    });
  } catch (error) {
    console.error('Error in updateWater:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 5. Get USDA / Curated Meal suggestions for empty meal slots
exports.getMealSuggestions = async (req, res) => {
  try {
    const suggestions = {
      breakfast: {
        title: 'USDA Protein Berry Oatmeal',
        calories: 380,
        protein: 26,
        carbs: 52,
        fat: 8,
        source: 'USDA',
        category: 'Grains & Oats',
        iconType: 'bakery_dining',
        servingSize: '1 bowl (250g)',
      },
      lunch: {
        title: 'USDA Grilled Herb Salmon Bowl',
        calories: 540,
        protein: 42,
        carbs: 45,
        fat: 16,
        source: 'USDA',
        category: 'Seafood',
        iconType: 'set_meal',
        servingSize: '1 bowl (350g)',
      },
      dinner: {
        title: 'USDA Lean Roast Turkey & Sweet Potato',
        calories: 490,
        protein: 46,
        carbs: 42,
        fat: 10,
        source: 'USDA',
        category: 'Poultry & Meat',
        iconType: 'lunch_dining',
        servingSize: '1 plate (380g)',
      },
      snack: {
        title: 'USDA Greek Yogurt & Almond Crunch',
        calories: 220,
        protein: 20,
        carbs: 14,
        fat: 7,
        source: 'USDA',
        category: 'Dairy & Eggs',
        iconType: 'icecream',
        servingSize: '1 cup (180g)',
      },
    };

    res.status(200).json({
      success: true,
      suggestions,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// 6. Get nutrition history for calendar days
exports.getNutritionHistory = async (req, res) => {
  try {
    const uid = req.params.uid || req.query.uid;
    const { startDate, endDate } = req.query;

    if (!uid) {
      return res.status(400).json({ success: false, message: 'User ID is required' });
    }

    const query = { uid };
    if (startDate && endDate) {
      query.date = { $gte: startDate, $lte: endDate };
    }

    const history = await UserDailyNutrition.find(query)
      .select('date consumedCalories targetCalories waterGlasses meals')
      .sort({ date: 1 });

    const summaryMap = {};
    history.forEach((h) => {
      summaryMap[h.date] = {
        date: h.date,
        consumedCalories: h.consumedCalories || 0,
        targetCalories: h.targetCalories || 2400,
        waterGlasses: h.waterGlasses || 0,
        mealCount: h.meals ? h.meals.length : 0,
        hasLogged: (h.consumedCalories > 0 || (h.meals && h.meals.length > 0)),
      };
    });

    res.status(200).json({
      success: true,
      history: summaryMap,
    });
  } catch (error) {
    console.error('Error in getNutritionHistory:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

