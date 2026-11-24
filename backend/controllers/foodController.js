const FoodItem = require('../models/FoodItem');
const indianFoodComposition = require('../data/indianFoodComposition');
const https = require('https');

// Fast in-memory caches
const offSearchCache = new Map();
const usdaSearchCache = new Map();

// Helper to fetch JSON from URL with timeout
function fetchJson(url, timeoutMs = 3500) {
  return new Promise((resolve) => {
    try {
      const parsedUrl = new URL(url);
      const options = {
        hostname: parsedUrl.hostname,
        path: parsedUrl.pathname + parsedUrl.search,
        method: 'GET',
        headers: {
          'User-Agent': 'NeuroFitAdmin - Web - Version 1.0 (contact@neurofit.org)',
          'Accept': 'application/json',
        },
      };

      const req = https.get(options, (res) => {
        let rawData = '';
        res.on('data', (chunk) => {
          rawData += chunk;
        });
        res.on('end', () => {
          try {
            const parsedData = JSON.parse(rawData);
            resolve(parsedData);
          } catch (e) {
            resolve(null);
          }
        });
      });

      req.on('error', () => resolve(null));
      req.setTimeout(timeoutMs, () => {
        req.destroy();
        resolve(null);
      });
    } catch (e) {
      resolve(null);
    }
  });
}

// Map USDA FoodData Central item to NeuroFit schema
function mapUsdaFoodToNeuroFit(food) {
  const nutrients = food.foodNutrients || [];

  function getNutrientVal(nutrientIds, nameKeywords = []) {
    for (const n of nutrients) {
      if (nutrientIds.includes(n.nutrientId) || nutrientIds.includes(parseInt(n.nutrientNumber))) {
        return parseFloat(n.value) || 0;
      }
      const nName = (n.nutrientName || '').toLowerCase();
      if (nameKeywords.some((k) => nName.includes(k.toLowerCase()))) {
        return parseFloat(n.value) || 0;
      }
    }
    return 0;
  }

  const calories = Math.round(getNutrientVal([1008, 208], ['energy']));
  const protein = parseFloat(getNutrientVal([1003, 203], ['protein']).toFixed(1));
  const fat = parseFloat(getNutrientVal([1004, 204], ['total lipid', 'fat']).toFixed(1));
  const carbs = parseFloat(getNutrientVal([1005, 205], ['carbohydrate']).toFixed(1));
  const fiber = parseFloat(getNutrientVal([1079, 291], ['fiber', 'dietary']).toFixed(1));
  const sugar = parseFloat(getNutrientVal([2000, 269], ['sugars', 'total sugars']).toFixed(1));
  const sodium = Math.round(getNutrientVal([1093, 307], ['sodium']));
  const potassium = Math.round(getNutrientVal([1092, 306], ['potassium']));
  const calcium = Math.round(getNutrientVal([1087, 301], ['calcium']));
  const iron = parseFloat(getNutrientVal([1089, 303], ['iron']).toFixed(1));
  const cholesterol = Math.round(getNutrientVal([1253, 601], ['cholesterol']));
  const saturatedFat = parseFloat(getNutrientVal([1258, 606], ['saturated']).toFixed(1));

  let category = 'General';
  const desc = (food.description || '').toLowerCase();
  const foodCat = (food.foodCategory || '').toLowerCase();
  if (desc.includes('apple') || desc.includes('fruit') || desc.includes('banana') || desc.includes('berry')) category = 'Fruits';
  else if (desc.includes('chicken') || desc.includes('turkey') || desc.includes('beef') || desc.includes('meat') || desc.includes('egg')) category = 'Poultry & Meat';
  else if (desc.includes('rice') || desc.includes('oat') || desc.includes('bread') || desc.includes('cereal') || desc.includes('flour')) category = 'Grains & Oats';
  else if (desc.includes('milk') || desc.includes('yogurt') || desc.includes('cheese') || desc.includes('paneer') || desc.includes('butter')) category = 'Dairy & Eggs';
  else if (desc.includes('almond') || desc.includes('nut') || desc.includes('seed') || desc.includes('peanut')) category = 'Nuts & Seeds';
  else if (desc.includes('fish') || desc.includes('salmon') || desc.includes('tuna') || desc.includes('shrimp')) category = 'Seafood';
  else if (desc.includes('spinach') || desc.includes('broccoli') || desc.includes('vegetable') || desc.includes('potato') || desc.includes('salad')) category = 'Vegetables & Greens';
  else if (desc.includes('protein') || desc.includes('whey') || desc.includes('shake')) category = 'Supplements & Shakes';
  else if (desc.includes('snack') || desc.includes('bar') || desc.includes('cracker')) category = 'Healthy Snacks';

  // Calculate Nutri-Score heuristic
  let nutriscore = 'A';
  if (sugar > 20 || saturatedFat > 10 || sodium > 800) nutriscore = 'D';
  else if (sugar > 12 || saturatedFat > 5 || sodium > 500) nutriscore = 'C';
  else if (sugar > 5 || fat > 15) nutriscore = 'B';

  const servingGrams = parseFloat(food.servingSize) || 100;
  const servingUnit = food.servingSizeUnit || 'g';

  return {
    id: `usda_${food.fdcId || Date.now()}`,
    barcode: food.gtinUpc || '',
    name: food.description || 'USDA Food Item',
    brand: food.brandOwner || food.brandName || 'USDA FoodData Central Verified',
    category,
    servingSize: `${servingGrams}${servingUnit}`,
    servingUnit,
    servingWeightGrams: servingGrams,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    sugar,
    sodium,
    potassium,
    calcium,
    iron,
    cholesterol,
    saturatedFat,
    nutriscore,
    novaGroup: food.dataType === 'Branded' ? 3 : 1,
    imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
    thumbnailUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&auto=format&fit=crop&q=80',
    ingredients: (food.ingredients || '').split(',').map((s) => s.trim()).filter(Boolean),
    ingredientText: food.ingredients || '',
    allergens: [],
    vitamins: `USDA FDC #${food.fdcId} • Calcium: ${calcium}mg, Iron: ${iron}mg, Potassium: ${potassium}mg`,
    isVerified: true,
    source: 'USDA_FoodData',
    isActive: true,
  };
}

// Map Open Food Facts item to NeuroFit schema
function mapOffProductToNeuroFit(product) {
  const nutriments = product.nutriments || {};
  const nutriscore = (product.nutriscore_grade || 'Unknown').toUpperCase();

  let category = 'General';
  const catTags = (product.categories_tags || []).join(' ').toLowerCase();
  if (catTags.includes('fruit') || catTags.includes('apple') || catTags.includes('berry')) category = 'Fruits';
  else if (catTags.includes('meat') || catTags.includes('chicken') || catTags.includes('poultry') || catTags.includes('beef')) category = 'Poultry & Meat';
  else if (catTags.includes('cereal') || catTags.includes('oat') || catTags.includes('grain') || catTags.includes('bread')) category = 'Grains & Oats';
  else if (catTags.includes('dairy') || catTags.includes('milk') || catTags.includes('yogurt') || catTags.includes('egg') || catTags.includes('cheese')) category = 'Dairy & Eggs';
  else if (catTags.includes('nut') || catTags.includes('seed') || catTags.includes('almond')) category = 'Nuts & Seeds';
  else if (catTags.includes('fish') || catTags.includes('seafood') || catTags.includes('salmon')) category = 'Seafood';
  else if (catTags.includes('vegetable') || catTags.includes('salad') || catTags.includes('green')) category = 'Vegetables & Greens';
  else if (catTags.includes('supplement') || catTags.includes('whey') || catTags.includes('protein')) category = 'Supplements & Shakes';
  else if (catTags.includes('snack') || catTags.includes('bar') || catTags.includes('cracker')) category = 'Healthy Snacks';

  return {
    id: `off_${product.code || Date.now()}`,
    barcode: product.code || '',
    name: product.product_name || product.product_name_en || 'Unnamed Food Item',
    brand: product.brands || '',
    category,
    servingSize: product.serving_size || '100g',
    servingUnit: 'g',
    servingWeightGrams: parseFloat(product.serving_quantity) || 100,
    calories: Math.round(nutriments['energy-kcal_100g'] || nutriments['energy-kcal'] || ((nutriments.energy_100g || 0) / 4.184) || 0),
    protein: parseFloat((nutriments.proteins_100g || nutriments.proteins || 0).toFixed(1)),
    carbs: parseFloat((nutriments.carbohydrates_100g || nutriments.carbohydrates || 0).toFixed(1)),
    fat: parseFloat((nutriments.fat_100g || nutriments.fat || 0).toFixed(1)),
    fiber: parseFloat((nutriments.fiber_100g || nutriments.fiber || 0).toFixed(1)),
    sugar: parseFloat((nutriments.sugars_100g || nutriments.sugars || 0).toFixed(1)),
    sodium: Math.round((nutriments.sodium_100g || nutriments.sodium || 0) * 1000), // convert g to mg
    potassium: Math.round((nutriments.potassium_100g || 0) * 1000),
    saturatedFat: parseFloat((nutriments['saturated-fat_100g'] || 0).toFixed(1)),
    nutriscore: ['A', 'B', 'C', 'D', 'E'].includes(nutriscore) ? nutriscore : 'Unknown',
    novaGroup: product.nova_group || null,
    imageUrl: product.image_url || product.image_front_url || product.image_front_small_url || '',
    thumbnailUrl: product.image_small_url || product.image_front_small_url || '',
    ingredients: (product.ingredients_text || '').split(',').map((s) => s.trim()).filter(Boolean),
    ingredientText: product.ingredients_text || '',
    allergens: (product.allergens_tags || []).map((a) => a.replace('en:', '').replace(/-/g, ' ')),
    vitamins: 'Open Food Facts Public Dataset Verified',
    isVerified: true,
    source: 'OpenFoodFacts',
    isActive: true,
  };
}

// 1. GET ALL FOODS (with Search, Category, Pagination & Lazy Loading support)
exports.getAllFoods = async (req, res) => {
  try {
    const { search, category, nutriscore, page, limit, sort } = req.query;
    const filter = {};

    if (category && category !== 'All Foods' && category !== 'All') {
      filter.category = new RegExp(`^${category}$`, 'i');
    }

    if (nutriscore && nutriscore !== 'All') {
      filter.nutriscore = nutriscore.toUpperCase();
    }

    if (search && search.trim()) {
      const s = search.trim();
      const searchRegex = new RegExp(s, 'i');
      filter.$or = [
        { name: searchRegex },
        { brand: searchRegex },
        { category: searchRegex },
        { barcode: searchRegex },
        { ingredientText: searchRegex },
      ];
    }

    let sortOption = { sortOrder: 1, createdAt: -1 };
    if (sort === 'calories_asc') sortOption = { calories: 1 };
    else if (sort === 'calories_desc') sortOption = { calories: -1 };
    else if (sort === 'protein_desc') sortOption = { protein: -1 };
    else if (sort === 'name_asc') sortOption = { name: 1 };

    let query = FoodItem.find(filter).sort(sortOption);

    if (limit && parseInt(limit) > 0) {
      const p = parseInt(page) || 1;
      const l = parseInt(limit);
      query = query.skip((p - 1) * l).limit(l);
    }

    const [foods, totalCount] = await Promise.all([
      query.lean(),
      FoodItem.countDocuments(filter),
    ]);

    res.json({
      success: true,
      totalCount,
      count: foods.length,
      page: parseInt(page) || 1,
      data: foods,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 2. GET FOOD BY ID OR BARCODE
exports.getFoodById = async (req, res) => {
  try {
    const { id } = req.params;
    let food = await FoodItem.findOne({ $or: [{ id }, { barcode: id }] });

    if (!food) {
      // If not in local DB, attempt lookup via Open Food Facts API
      try {
        const offUrl = `https://world.openfoodfacts.org/api/v2/product/${id}.json`;
        const offData = await fetchJson(offUrl, 3000);
        if (offData && offData.status === 1 && offData.product) {
          const mapped = mapOffProductToNeuroFit(offData.product);
          return res.json({ success: true, data: mapped, source: 'OpenFoodFacts_Live' });
        }
      } catch (offErr) {
        // Fall through
      }
      return res.status(404).json({ success: false, message: 'Food item not found' });
    }

    res.json({ success: true, data: food });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 3. SEARCH LIVE OPEN FOOD FACTS API (with Cache + Atlas Fallback)
exports.searchOpenFoodFacts = async (req, res) => {
  try {
    const query = (req.query.query || req.query.q || '').trim();
    const page = parseInt(req.query.page) || 1;
    const pageSize = parseInt(req.query.pageSize) || 24;

    if (!query) {
      return res.json({ success: true, count: 0, data: [] });
    }

    const cacheKey = `${query.toLowerCase()}_${page}_${pageSize}`;
    if (offSearchCache.has(cacheKey)) {
      const cached = offSearchCache.get(cacheKey);
      return res.json({
        success: true,
        fromCache: true,
        totalCount: cached.totalCount,
        count: cached.data.length,
        page,
        data: cached.data,
      });
    }

    const encodedQuery = encodeURIComponent(query);
    const offUrl = `https://world.openfoodfacts.org/cgi/search.pl?search_terms=${encodedQuery}&search_simple=1&action=process&json=1&page=${page}&page_size=${pageSize}`;

    const data = await fetchJson(offUrl, 3500);
    let mapped = [];

    if (data && data.products) {
      mapped = (data.products || [])
        .filter((p) => p.product_name || p.product_name_en || p.product_name_fr || p.brands)
        .map(mapOffProductToNeuroFit);
    }

    // Fallback: If OFF returned nothing or timed out, query local MongoDB Atlas foods
    if (mapped.length === 0) {
      const searchRegex = new RegExp(query, 'i');
      const localMatches = await FoodItem.find({
        $or: [
          { name: searchRegex },
          { brand: searchRegex },
          { category: searchRegex },
          { ingredientText: searchRegex },
        ],
      })
        .limit(10)
        .lean();

      mapped = localMatches;
    }

    // Cache successful search results (only if items found)
    if (mapped.length > 0) {
      if (offSearchCache.size > 100) {
        const firstKey = offSearchCache.keys().next().value;
        offSearchCache.delete(firstKey);
      }
      offSearchCache.set(cacheKey, { totalCount: data?.count || mapped.length, data: mapped });
    }

    res.json({
      success: true,
      totalCount: data?.count || mapped.length,
      count: mapped.length,
      page,
      data: mapped,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 3a. SEARCH INDIAN FOOD COMPOSITION TABLES (ICMR-NIN IFCT) - Instant < 2ms
exports.searchIfctFoods = async (req, res) => {
  try {
    const query = (req.query.query || req.query.q || '').trim().toLowerCase();
    const category = (req.query.category || '').trim().toLowerCase();

    let matches = indianFoodComposition;

    if (query) {
      matches = matches.filter((item) => {
        const nameMatch = item.name.toLowerCase().includes(query);
        const hindiMatch = (item.hindiName || '').toLowerCase().includes(query);
        const catMatch = item.category.toLowerCase().includes(query);
        const brandMatch = (item.brand || '').toLowerCase().includes(query);
        return nameMatch || hindiMatch || catMatch || brandMatch;
      });
    }

    if (category && category !== 'all' && category !== 'all foods') {
      matches = matches.filter((item) => item.category.toLowerCase() === category);
    }

    res.json({
      success: true,
      source: 'ICMR_NIN_IFCT',
      totalCount: matches.length,
      count: matches.length,
      data: matches,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 3b. SEARCH USDA FOODDATA CENTRAL API (100% Free Public Nutrition Dataset)
exports.searchUsdaFoods = async (req, res) => {
  try {
    const query = (req.query.query || req.query.q || '').trim();
    const page = parseInt(req.query.page) || 1;
    const pageSize = parseInt(req.query.pageSize) || 20;

    if (!query) {
      return res.json({ success: true, count: 0, data: [] });
    }

    const cacheKey = `${query.toLowerCase()}_${page}_${pageSize}`;
    if (usdaSearchCache.has(cacheKey)) {
      const cached = usdaSearchCache.get(cacheKey);
      return res.json({
        success: true,
        fromCache: true,
        source: 'USDA_FoodData',
        totalCount: cached.totalCount,
        count: cached.data.length,
        page,
        data: cached.data,
      });
    }

    const apiKey = process.env.USDA_API_KEY || 'DEMO_KEY';
    const encodedQuery = encodeURIComponent(query);
    const usdaUrl = `https://api.nal.usda.gov/fdc/v1/foods/search?query=${encodedQuery}&api_key=${apiKey}&pageNumber=${page}&pageSize=${pageSize}`;

    const data = await fetchJson(usdaUrl, 4000);
    let mapped = [];

    if (data && data.foods) {
      mapped = data.foods.map(mapUsdaFoodToNeuroFit);
    }

    // Fallback to local MongoDB Atlas foods if USDA timed out
    if (mapped.length === 0) {
      const searchRegex = new RegExp(query, 'i');
      const localMatches = await FoodItem.find({
        $or: [
          { name: searchRegex },
          { brand: searchRegex },
          { category: searchRegex },
        ],
      })
        .limit(10)
        .lean();

      mapped = localMatches;
    }

    if (mapped.length > 0) {
      if (usdaSearchCache.size > 100) {
        const firstKey = usdaSearchCache.keys().next().value;
        usdaSearchCache.delete(firstKey);
      }
      usdaSearchCache.set(cacheKey, { totalCount: data?.totalHits || mapped.length, data: mapped });
    }

    res.json({
      success: true,
      source: 'USDA_FoodData',
      totalCount: data?.totalHits || mapped.length,
      count: mapped.length,
      page,
      data: mapped,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 3c. SEARCH UNIFIED LIVE NUTRITION (Aggregates IFCT + USDA + Open Food Facts)
exports.searchUnifiedLiveFoods = async (req, res) => {
  try {
    const query = (req.query.query || req.query.q || '').trim();
    const source = (req.query.source || 'all').toLowerCase(); // 'all', 'ifct', 'usda', 'off'

    if (!query) {
      // Default: Return staple IFCT Indian Foods
      return res.json({
        success: true,
        source: 'ICMR_NIN_IFCT',
        totalCount: indianFoodComposition.length,
        count: indianFoodComposition.length,
        data: indianFoodComposition,
      });
    }

    const aggregated = [];
    const seenNames = new Set();

    // 1. Always check IFCT Indian database first (< 1ms)
    if (source === 'all' || source === 'ifct') {
      const qLower = query.toLowerCase();
      const ifctMatches = indianFoodComposition.filter((item) => {
        return (
          item.name.toLowerCase().includes(qLower) ||
          (item.hindiName || '').toLowerCase().includes(qLower) ||
          item.category.toLowerCase().includes(qLower)
        );
      });

      for (const item of ifctMatches) {
        if (!seenNames.has(item.name.toLowerCase())) {
          seenNames.add(item.name.toLowerCase());
          aggregated.push(item);
        }
      }
    }

    // 2. Query USDA FoodData & Open Food Facts in parallel
    const promises = [];

    if (source === 'all' || source === 'usda') {
      const apiKey = process.env.USDA_API_KEY || 'DEMO_KEY';
      const encodedQuery = encodeURIComponent(query);
      const usdaUrl = `https://api.nal.usda.gov/fdc/v1/foods/search?query=${encodedQuery}&api_key=${apiKey}&pageNumber=1&pageSize=15`;
      promises.push(
        fetchJson(usdaUrl, 3500).then((data) => {
          if (data?.foods) {
            return data.foods.map(mapUsdaFoodToNeuroFit);
          }
          return [];
        })
      );
    }

    if (source === 'all' || source === 'off') {
      const encodedQuery = encodeURIComponent(query);
      const offUrl = `https://world.openfoodfacts.org/cgi/search.pl?search_terms=${encodedQuery}&search_simple=1&action=process&json=1&page=1&page_size=15`;
      promises.push(
        fetchJson(offUrl, 3500).then((data) => {
          if (data?.products) {
            return (data.products || [])
              .filter((p) => p.product_name || p.product_name_en || p.brands)
              .map(mapOffProductToNeuroFit);
          }
          return [];
        })
      );
    }

    const results = await Promise.allSettled(promises);
    for (const resItem of results) {
      if (resItem.status === 'fulfilled' && Array.isArray(resItem.value)) {
        for (const food of resItem.value) {
          const key = food.name.toLowerCase().trim();
          if (!seenNames.has(key)) {
            seenNames.add(key);
            aggregated.push(food);
          }
        }
      }
    }

    // Fallback: If still empty, query MongoDB Atlas FoodItem collection
    if (aggregated.length === 0) {
      const searchRegex = new RegExp(query, 'i');
      const dbMatches = await FoodItem.find({
        $or: [
          { name: searchRegex },
          { brand: searchRegex },
          { category: searchRegex },
        ],
      })
        .limit(10)
        .lean();

      for (const f of dbMatches) {
        aggregated.push(f);
      }
    }

    // Sort USDA meals FIRST as requested by user
    aggregated.sort((a, b) => {
      const isUsdaA = (a.source || '').toUpperCase().includes('USDA');
      const isUsdaB = (b.source || '').toUpperCase().includes('USDA');
      if (isUsdaA && !isUsdaB) return -1;
      if (!isUsdaA && isUsdaB) return 1;
      return 0;
    });

    res.json({
      success: true,
      source: source.toUpperCase(),
      totalCount: aggregated.length,
      count: aggregated.length,
      data: aggregated,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 4. CREATE FOOD ITEM
exports.createFood = async (req, res) => {
  try {
    const payload = req.body;
    if (!payload.id) {
      payload.id = `food_${Date.now()}`;
    }

    const food = await FoodItem.create(payload);

    const io = req.app.get('socketio') || req.io;
    if (io) {
      io.emit('food_created', food);
    }

    res.status(201).json({ success: true, data: food });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 5. UPDATE FOOD ITEM
exports.updateFood = async (req, res) => {
  try {
    const { id } = req.params;
    const food = await FoodItem.findOneAndUpdate(
      { $or: [{ id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }] },
      { $set: req.body },
      { new: true }
    );

    if (!food) {
      return res.status(404).json({ success: false, message: 'Food item not found' });
    }

    const io = req.app.get('socketio') || req.io;
    if (io) {
      io.emit('food_updated', food);
    }

    res.json({ success: true, data: food });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 6. DELETE FOOD ITEM
exports.deleteFood = async (req, res) => {
  try {
    const { id } = req.params;
    const food = await FoodItem.findOneAndDelete({
      $or: [{ id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }],
    });

    if (!food) {
      return res.status(404).json({ success: false, message: 'Food item not found' });
    }

    const io = req.app.get('socketio') || req.io;
    if (io) {
      io.emit('food_deleted', { id: food.id });
    }

    res.json({ success: true, message: 'Food item deleted successfully', id: food.id });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
