const https = require('https');
const Recipe = require('../models/Recipe');
const DailyFeaturedRecipe = require('../models/DailyFeaturedRecipe');
const usdaHealthyRecipes = require('../data/usdaHealthyRecipes');

// Helper to fetch JSON from URL with strict timeout
function fetchJson(url, timeoutMs = 3500) {
  return new Promise((resolve) => {
    try {
      const parsedUrl = new URL(url);
      const options = {
        hostname: parsedUrl.hostname,
        path: parsedUrl.pathname + parsedUrl.search,
        method: 'GET',
        headers: {
          'User-Agent': 'NeuroFit-App - Web - Version 1.0 (rohit@neurofit.io)',
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

// Comprehensive Indian Recipes Dictionary for Instant Live Search (< 10ms)
const indianKnownDishes = {
  samosa: {
    title: 'Crispy Baked Punjabi Samosa',
    cuisine: 'North Indian',
    dietaryType: 'Vegetarian',
    category: 'Healthy Snacks',
    prepTimeMinutes: 25,
    cookTimeMinutes: 20,
    totalTime: '45 mins',
    calories: 210,
    protein: 6.5,
    carbs: 28.0,
    fat: 8.5,
    fiber: 3.5,
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Boiled Potatoes (Mashed)', quantity: '3', unit: 'medium' },
      { name: 'Green Peas (Matar)', quantity: '1/2', unit: 'cup' },
      { name: 'Whole Wheat / All-Purpose Flour', quantity: '1.5', unit: 'cups' },
      { name: 'Ajwain (Carom Seeds)', quantity: '1', unit: 'tsp' },
      { name: 'Garam Masala, Amchur & Roasted Cumin', quantity: '2', unit: 'tsp' },
      { name: 'Green Chillies & Ginger Paste', quantity: '1', unit: 'tbsp' },
      { name: 'Cold-Pressed Oil / Ghee', quantity: '1', unit: 'tbsp' },
    ],
    ingredientList: [
      '3 medium Boiled Potatoes mashed',
      '1/2 cup Green Peas (Matar)',
      '1.5 cups Whole Wheat / Samosa Flour',
      '1 tsp Carom Seeds (Ajwain)',
      '2 tsp Garam Masala, Amchur & Roasted Cumin',
      '1 tbsp Ginger Green Chilli Paste',
      '1 tbsp Oil for air-frying or light brush',
    ],
    steps: [
      'Knead flour with ajwain, salt, and 1 tbsp oil into a firm stiff dough. Rest for 20 minutes.',
      'In a pan, sauté ginger-green chillies, green peas, mashed potatoes, and dry spices until fragrant. Let cool.',
      'Roll out oval dough portions, cut in half, form a cone shape, and stuff with potato filling.',
      'Seal edges firmly with water dab.',
      'Air-fry at 180°C for 16-18 minutes until golden and flaky, or bake at 200°C. Serve with tamarind & mint chutney.',
    ],
    chefTips: 'Air-frying or baking instead of deep-frying reduces calories by 60% while maintaining the signature crispy crust.',
    tags: ['Street Food', 'Air Fryer', 'Vegetarian', 'North Indian Classic'],
  },
  biryani: {
    title: 'Hyderabadi Dum Chicken Biryani',
    cuisine: 'Mughlai',
    dietaryType: 'Non-Vegetarian',
    category: 'Rice & Biryani',
    prepTimeMinutes: 30,
    cookTimeMinutes: 35,
    totalTime: '65 mins',
    calories: 490,
    protein: 38.0,
    carbs: 52.0,
    fat: 14.0,
    fiber: 4.0,
    imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Basmati Rice (Aged)', quantity: '1.5', unit: 'cups' },
      { name: 'Chicken Breast / Thighs (Skinless)', quantity: '350', unit: 'g' },
      { name: 'Greek / Hung Curd', quantity: '1/2', unit: 'cup' },
      { name: 'Biryani Masala & Shahi Jeera', quantity: '2', unit: 'tbsp' },
      { name: 'Fried Onions (Birista)', quantity: '1/2', unit: 'cup' },
      { name: 'Saffron Milk & Mint Leaves', quantity: '2', unit: 'tbsp' },
    ],
    ingredientList: [
      '1.5 cups Aged Basmati Rice',
      '350g Lean Chicken Breast marinated',
      '1/2 cup Hung Curd with Biryani Spices',
      '1/2 cup Crisp Golden Fried Onions',
      'Fresh Mint, Coriander & Saffron Milk',
      'Whole Spices (Cardamom, Cloves, Bay Leaf)',
    ],
    steps: [
      'Marinate chicken in yogurt, ginger-garlic paste, biryani masala, and mint for 30 minutes.',
      'Par-boil soaked basmati rice with whole spices until 70% cooked. Drain well.',
      'Layer marinated chicken at the bottom of a heavy pot, top with par-boiled rice, fried onions, mint, and saffron milk.',
      'Seal with lid and cook on low dum heat for 25 minutes.',
      'Gently fluff rice and serve hot with fresh cucumber raita.',
    ],
    chefTips: 'Cook on low dum heat with a tight seal to lock all aromatic vapor and infuse succulent spices into the rice.',
    tags: ['Royal Feast', 'High Protein', 'Authentic Dum'],
  },
  butter_chicken: {
    title: 'Low-Fat Murgh Makhani (Fit Butter Chicken)',
    cuisine: 'North Indian',
    dietaryType: 'Non-Vegetarian',
    category: 'Curries & Dals',
    prepTimeMinutes: 20,
    cookTimeMinutes: 25,
    totalTime: '45 mins',
    calories: 420,
    protein: 44.0,
    carbs: 16.0,
    fat: 16.0,
    fiber: 3.5,
    imageUrl: 'https://images.unsplash.com/photo-1603894584373-5ac82b2ae398?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Grilled Chicken Breast Cubes', quantity: '350', unit: 'g' },
      { name: 'Fresh Tomato Puree', quantity: '2', unit: 'cups' },
      { name: 'Cashew & Melon Seed Paste', quantity: '2', unit: 'tbsp' },
      { name: 'Kasuri Methi & Garam Masala', quantity: '1', unit: 'tbsp' },
      { name: 'Low-Fat Cream or Greek Yogurt', quantity: '2', unit: 'tbsp' },
      { name: 'Butter / Ghee', quantity: '1', unit: 'tbsp' },
    ],
    ingredientList: [
      '350g Char-grilled Chicken Breast Cubes',
      '2 cups Ripe Tomato Puree',
      '2 tbsp Cashew & Melon Seed paste for velvety texture',
      '1 tbsp Kasuri Methi (Dried Fenugreek)',
      '1 tbsp Pure Ghee / Grass-fed Butter',
      '2 tbsp Low-Fat Cream or Hung Curd',
    ],
    steps: [
      'Marinate chicken in tandoori spices and grill until smoky and charred.',
      'In a pan, cook tomato puree with ginger-garlic paste and Kashmiri chilli until thickened.',
      'Add cashew paste, kasuri methi, garam masala, and 1/2 cup warm water to create a silky makhani gravy.',
      'Add grilled chicken chunks and simmer for 6-8 minutes.',
      'Finish with crushed kasuri methi and 1 tbsp low-fat cream. Serve with whole wheat naan or jeera rice.',
    ],
    chefTips: 'Rub kasuri methi between palms before adding to release aromatic essential oils into the makhani gravy.',
    tags: ['North Indian Classic', 'High Protein', 'Rich Makhani Gravy'],
  },
  paneer_tikka: {
    title: 'Tandoori Paneer Tikka (Protein Rich)',
    cuisine: 'North Indian',
    dietaryType: 'Vegetarian',
    category: 'Healthy Snacks',
    prepTimeMinutes: 20,
    cookTimeMinutes: 15,
    totalTime: '35 mins',
    calories: 340,
    protein: 24.0,
    carbs: 12.0,
    fat: 20.0,
    fiber: 3.0,
    imageUrl: 'https://images.unsplash.com/photo-1599488615731-7e5c2823ff28?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Low-Fat Malai Paneer Cubes', quantity: '200', unit: 'g' },
      { name: 'Bell Peppers & Red Onion Cubes', quantity: '1.5', unit: 'cups' },
      { name: 'Hung Curd / Greek Yogurt', quantity: '1/2', unit: 'cup' },
      { name: 'Mustard Oil & Kashmiri Red Chilli', quantity: '1', unit: 'tbsp' },
      { name: 'Chaat Masala & Roasted Besan', quantity: '1.5', unit: 'tbsp' },
    ],
    ingredientList: [
      '200g Fresh Low-Fat Paneer Cubes',
      '1.5 cups Diced Capsicum & Red Onions',
      '1/2 cup Thick Hung Curd',
      '1 tbsp Mustard Oil infused with Kashmiri Chilli',
      '1.5 tbsp Roasted Gram Flour (Besan)',
      '1 tsp Chaat Masala & Lemon Juice',
    ],
    steps: [
      'Whisk hung curd with mustard oil, roasted besan, ginger-garlic paste, and tandoori spices.',
      'Gently coat paneer cubes, bell peppers, and onion petals in the marinade. Rest for 15 mins.',
      'Thread onto skewers and air-fry at 200°C for 10-12 mins or grill on a tawa until charred at edges.',
      'Sprinkle chaat masala and fresh coriander, serve with spicy green mint chutney.',
    ],
    chefTips: 'Smoked mustard oil gives the authentic highway dhaba tandoor flavor without requiring a charcoal oven.',
    tags: ['High Protein', 'Vegetarian Star', 'Tandoori Grill', 'Low Carb'],
  },
  palak_paneer: {
    title: 'Homestyle Palak Paneer (Iron & Protein Power)',
    cuisine: 'North Indian',
    dietaryType: 'Vegetarian',
    category: 'Curries & Dals',
    prepTimeMinutes: 15,
    cookTimeMinutes: 15,
    totalTime: '30 mins',
    calories: 310,
    protein: 22.0,
    carbs: 14.0,
    fat: 18.0,
    fiber: 6.0,
    imageUrl: 'https://images.unsplash.com/photo-1610057099443-fde8c4d50f91?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Fresh Spinach (Palak) Leaves', quantity: '300', unit: 'g' },
      { name: 'Paneer Cubes', quantity: '180', unit: 'g' },
      { name: 'Garlic Cloves (Finely Chopped)', quantity: '6', unit: 'cloves' },
      { name: 'Green Chillies & Ginger', quantity: '1', unit: 'tbsp' },
      { name: 'Cumin Seeds & Garam Masala', quantity: '1.5', unit: 'tsp' },
      { name: 'Olive Oil / Ghee', quantity: '1', unit: 'tbsp' },
    ],
    ingredientList: [
      '300g Fresh Organic Spinach blanched and pureed',
      '180g Soft Paneer Cubes',
      '6 Garlic cloves minced (Lehsuni flavor)',
      '1 tbsp Ginger-Green Chilli Paste',
      '1 tbsp Ghee / Olive Oil',
      '1.5 tsp Cumin Seeds & Garam Masala',
    ],
    steps: [
      'Blanch spinach leaves in boiling water for 2 mins, immediately transfer to ice water to retain vibrant green color.',
      'Puree spinach with green chillies until smooth.',
      'Sauté minced garlic and cumin seeds in ghee until aromatic and golden brown.',
      'Add pureed spinach, salt, and garam masala. Simmer on low heat for 5 minutes.',
      'Fold in paneer cubes and cook for 3 minutes. Garnish with a swirl of fresh cream or lemon juice.',
    ],
    chefTips: 'Ice water shock treatment preserves the bright emerald green color and nutrient integrity of the spinach.',
    tags: ['Iron Rich', 'Protein Packed', 'Desi Superfood'],
  },
  dal_makhani: {
    title: 'Slow-Cooked Punjabi Dal Makhani',
    cuisine: 'Punjabi',
    dietaryType: 'Vegetarian',
    category: 'Curries & Dals',
    prepTimeMinutes: 15,
    cookTimeMinutes: 40,
    totalTime: '55 mins',
    calories: 360,
    protein: 18.0,
    carbs: 48.0,
    fat: 11.0,
    fiber: 12.0,
    imageUrl: 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Whole Black Urad Dal (Soaked)', quantity: '1', unit: 'cup' },
      { name: 'Red Kidney Beans (Rajma)', quantity: '1/4', unit: 'cup' },
      { name: 'Ripe Tomato Puree', quantity: '1.5', unit: 'cups' },
      { name: 'Butter & Ghee', quantity: '1.5', unit: 'tbsp' },
      { name: 'Kashmiri Chilli & Kasuri Methi', quantity: '1.5', unit: 'tbsp' },
    ],
    ingredientList: [
      '1 cup Black Urad Dal soaked overnight',
      '1/4 cup Rajma Beans soaked overnight',
      '1.5 cups Fresh Tomato Puree',
      '1.5 tbsp Grass-Fed Butter & Ghee',
      '1.5 tbsp Kashmiri Chilli & Kasuri Methi',
    ],
    steps: [
      'Pressure cook black dal and rajma with salt and whole spices for 8-9 whistles until buttery soft.',
      'In a heavy pot, cook tomato puree with ginger-garlic paste and Kashmiri chilli.',
      'Add cooked dal along with cooking liquor and simmer on low heat for 30 minutes, mashing slightly against pot sides.',
      'Finish with butter, kasuri methi, and a light splash of low-fat cream.',
    ],
    chefTips: 'Slow simmering breaks down dal starches into a naturally creamy, rich texture without needing excess heavy cream.',
    tags: ['Slow Cooked', 'High Fiber', 'Comfort Food', 'Vegetarian'],
  },
  dosa: {
    title: 'Crispy Golden Masala Dosa with Sambar',
    cuisine: 'South Indian',
    dietaryType: 'Vegan',
    category: 'Breakfast',
    prepTimeMinutes: 10,
    cookTimeMinutes: 15,
    totalTime: '25 mins',
    calories: 320,
    protein: 9.0,
    carbs: 54.0,
    fat: 7.0,
    fiber: 5.0,
    imageUrl: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Fermented Rice & Urad Dal Batter', quantity: '1.5', unit: 'cups' },
      { name: 'Spiced Mustard Potato Mash', quantity: '1', unit: 'cup' },
      { name: 'Curry Leaves & Mustard Seeds', quantity: '1', unit: 'tsp' },
      { name: 'Turmeric & Green Chillies', quantity: '1/2', unit: 'tsp' },
    ],
    ingredientList: [
      '1.5 cups Fermented Rice & Urad Dal Batter',
      '1 cup Spiced Mustard Potato Mash (Aloo Masala)',
      '1 tsp Mustard Seeds & Fresh Curry Leaves',
      'Fresh Coconut & Tomato Chutneys',
    ],
    steps: [
      'Heat a seasoned cast iron tawa, pour a ladleful of fermented batter and swirl outwards into a thin crepe.',
      'Drizzle a few drops of sesame oil or ghee around the edges.',
      'Cook on medium heat until golden and crispy, then place the potato masala filling in the center.',
      'Fold and serve hot with piping hot toor dal sambar and coconut chutney.',
    ],
    chefTips: 'Splash a few drops of water on the hot tawa and wipe with a cloth before pouring batter for even crisping.',
    tags: ['Crispy', 'Fermented Gut Health', 'South Indian Staple', 'Vegan'],
  },
  pav_bhaji: {
    title: 'Mumbai Butter Pav Bhaji (High-Fiber Veggie Mash)',
    cuisine: 'Maharashtrian',
    dietaryType: 'Vegetarian',
    category: 'Main Course',
    prepTimeMinutes: 15,
    cookTimeMinutes: 20,
    totalTime: '35 mins',
    calories: 390,
    protein: 11.0,
    carbs: 62.0,
    fat: 11.0,
    fiber: 9.0,
    imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Boiled Mixed Veggies (Cauliflower, Peas, Potatoes, Carrots)', quantity: '2', unit: 'cups' },
      { name: 'Finely Chopped Red Onions & Capsicum', quantity: '1', unit: 'cup' },
      { name: 'Ripe Tomato Puree', quantity: '1.5', unit: 'cups' },
      { name: 'Pav Bhaji Masala & Kashmiri Chilli', quantity: '2', unit: 'tbsp' },
      { name: 'Grass-Fed Butter', quantity: '1.5', unit: 'tbsp' },
      { name: 'Whole Wheat Pav Buns', quantity: '2', unit: 'buns' },
    ],
    ingredientList: [
      '2 cups Boiled Mixed Veggies mashed',
      '1 cup Finely Chopped Onions & Capsicum',
      '1.5 cups Tomato Puree',
      '2 tbsp Authentic Mumbai Pav Bhaji Masala',
      '1.5 tbsp Butter',
      '2 Whole Wheat Pav Buns toasted',
    ],
    steps: [
      'Melt butter on a flat tawa, sauté chopped onions, capsicum, and ginger-garlic paste until aromatic.',
      'Add tomato puree, Kashmiri chilli powder, and pav bhaji masala. Cook for 5 minutes.',
      'Add boiled mashed vegetables and 1/2 cup warm water. Mash continuously with a potato masher until smooth.',
      'Simmer for 8 minutes, finish with a dollop of butter, chopped coriander, and a squeeze of lime.',
      'Toast pav buns with butter and coriander on the tawa and serve hot with chopped raw onions.',
    ],
    chefTips: 'Continuous mashing directly on the tawa blends the vegetable fibers into a rich, velvety consistency.',
    tags: ['Mumbai Street Food', 'High Fiber', 'Vegetarian', 'Party Favorite'],
  },
  chole_bhature: {
    title: 'Amritsari Chole with Fluffy Bhature',
    cuisine: 'Punjabi',
    dietaryType: 'Vegetarian',
    category: 'Main Course',
    prepTimeMinutes: 20,
    cookTimeMinutes: 25,
    totalTime: '45 mins',
    calories: 460,
    protein: 18.0,
    carbs: 68.0,
    fat: 14.0,
    fiber: 10.0,
    imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Kabuli Chickpeas (Soaked)', quantity: '1.5', unit: 'cups' },
      { name: 'Amritsari Chole Spice Blend & Anardana', quantity: '2', unit: 'tbsp' },
      { name: 'Onion-Tomato Puree & Ginger Juliennes', quantity: '1', unit: 'cup' },
      { name: 'Whole Wheat / Semolina Bhatura Dough', quantity: '2', unit: 'pieces' },
    ],
    ingredientList: [
      '1.5 cups Kabuli Chickpeas soaked overnight',
      '2 tbsp Amritsari Chole Masala & Dried Pomegranate',
      '1 cup Onion-Tomato Masala Gravy',
      '2 Baked / Lightly Fried Whole Wheat Bhature',
    ],
    steps: [
      'Pressure cook chickpeas with whole spices and tea bag for 6 whistles.',
      'In a pan, cook onion-tomato masala with ginger juliennes and chole spices.',
      'Add chickpeas and simmer for 15 minutes, lightly mashing some to thicken gravy.',
      'Roll bhatura dough and fry or air-fry until puffed and golden.',
      'Serve hot with pickled onions and green chillies.',
    ],
    chefTips: 'Soak chickpeas with a pinch of baking soda for the softest, melt-in-the-mouth texture.',
    tags: ['Punjabi Feast', 'High Protein', 'Rich Flavor'],
  },
  egg_bhurji: {
    title: 'Desi Masala Egg Bhurji (Scrambled Eggs)',
    cuisine: 'North Indian',
    dietaryType: 'Eggitarian',
    category: 'Breakfast',
    prepTimeMinutes: 10,
    cookTimeMinutes: 10,
    totalTime: '20 mins',
    calories: 280,
    protein: 24.0,
    carbs: 8.0,
    fat: 16.0,
    fiber: 2.0,
    imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Farm Fresh Eggs', quantity: '4', unit: 'whole' },
      { name: 'Finely Chopped Red Onions & Tomatoes', quantity: '1', unit: 'cup' },
      { name: 'Green Chillies & Fresh Coriander', quantity: '2', unit: 'tbsp' },
      { name: 'Turmeric, Red Chilli & Garam Masala', quantity: '1', unit: 'tsp' },
      { name: 'Olive Oil / Butter', quantity: '1', unit: 'tbsp' },
    ],
    ingredientList: [
      '4 Farm Fresh Eggs whisked lightly',
      '1 cup Finely Chopped Onions & Tomatoes',
      '2 Green Chillies & Fresh Coriander',
      '1 tsp Desi Spices (Turmeric, Pav Bhaji / Garam Masala)',
      '1 tbsp Olive Oil or Butter',
    ],
    steps: [
      'Heat oil in a pan, sauté onions, green chillies, and tomatoes until soft.',
      'Add turmeric, red chilli powder, and salt. Cook for 2 minutes.',
      'Pour in whisked eggs and scramble on medium heat for 3-4 minutes until soft and fluffy.',
      'Garnish with lots of fresh coriander and serve with whole wheat toast or paratha.',
    ],
    chefTips: 'Do not overcook the eggs; keep them soft and juicy for the best texture.',
    tags: ['Quick Breakfast', 'High Protein', 'Eggitarian Staple'],
  },
  chana_masala: {
    title: 'Protein-Packed Pindi Chana Masala',
    cuisine: 'Punjabi',
    dietaryType: 'Vegan',
    category: 'Curries & Dals',
    prepTimeMinutes: 15,
    cookTimeMinutes: 20,
    totalTime: '35 mins',
    calories: 340,
    protein: 19.0,
    carbs: 52.0,
    fat: 6.0,
    fiber: 14.0,
    imageUrl: 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Boiled White Chickpeas (Kabuli Chana)', quantity: '2', unit: 'cups' },
      { name: 'Onion-Tomato Puree', quantity: '1', unit: 'cup' },
      { name: 'Anardana (Dried Pomegranate) & Chana Masala', quantity: '2', unit: 'tbsp' },
      { name: 'Ginger Juliennes & Green Chillies', quantity: '1', unit: 'tbsp' },
    ],
    ingredientList: [
      '2 cups Boiled White Chickpeas',
      '1 cup Fresh Onion-Tomato Puree',
      '2 tbsp Roasted Spices & Pomegranate Seeds',
      'Fresh Ginger Juliennes & Coriander',
    ],
    steps: [
      'Sauté ginger juliennes, green chillies, and onion-tomato puree.',
      'Add boiled chickpeas and roasted spice blend with 1 cup hot water.',
      'Simmer for 15 minutes, lightly mashing some chickpeas for a rich thick gravy.',
      'Serve hot with steamed basmati rice or rotis.',
    ],
    chefTips: 'Dried pomegranate seeds (anardana) give authentic pindi chana its distinctive tangy undertone.',
    tags: ['Vegan Protein', 'High Fiber', 'Heart Healthy'],
  },
  masala_oats: {
    title: 'Savory Indian Desi Masala Oats',
    cuisine: 'Indian Fitness',
    dietaryType: 'Vegan',
    category: 'Breakfast',
    prepTimeMinutes: 5,
    cookTimeMinutes: 10,
    totalTime: '15 mins',
    calories: 260,
    protein: 12.0,
    carbs: 42.0,
    fat: 5.0,
    fiber: 8.0,
    imageUrl: 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?w=600&auto=format&fit=crop&q=80',
    ingredients: [
      { name: 'Rolled / Whole Oats', quantity: '1', unit: 'cup' },
      { name: 'Diced Mixed Veggies (Carrot, Beans, Peas)', quantity: '1', unit: 'cup' },
      { name: 'Mustard Seeds & Curry Leaves', quantity: '1', unit: 'tsp' },
      { name: 'Turmeric & Sambar Masala', quantity: '1', unit: 'tsp' },
    ],
    ingredientList: [
      '1 cup Rolled Whole Oats',
      '1 cup Diced Veggies (Carrot, Peas, Beans)',
      '1 tsp Mustard Seeds & Fresh Curry Leaves',
      '1 tsp Turmeric & Sambar Spice Blend',
    ],
    steps: [
      'Temper mustard seeds and curry leaves in 1 tsp oil, sauté veggies for 3 mins.',
      'Add oats, turmeric, sambar masala, and 2.5 cups water.',
      'Cook on medium heat for 6-8 minutes until thick and creamy.',
      'Finish with lemon juice and chopped coriander.',
    ],
    chefTips: 'Top with roasted peanuts or hemp seeds for extra crunch and essential omegas.',
    tags: ['Fast Cooking', 'Low GI', 'Heart Healthy', 'High Fiber'],
  },
};

// Convert TheMealDB Indian recipe item to NeuroFit schema
function mapMealDbToNeuroFit(meal) {
  const ingredients = [];
  const ingredientList = [];
  for (let i = 1; i <= 20; i++) {
    const ing = meal[`strIngredient${i}`];
    const measure = meal[`strMeasure${i}`];
    if (ing && ing.trim()) {
      ingredients.push({
        name: ing.trim(),
        quantity: measure ? measure.trim() : '',
        unit: '',
      });
      ingredientList.push(`${measure ? measure.trim() + ' ' : ''}${ing.trim()}`);
    }
  }

  const rawInstructions = meal.strInstructions || '';
  const steps = rawInstructions
    .split(/\r?\n/)
    .map((s) => s.trim())
    .filter((s) => s.length > 5 && !s.toLowerCase().startsWith('step'));

  const lowerText = `${meal.strMeal} ${ingredientList.join(' ')}`.toLowerCase();
  let dietaryType = 'Vegetarian';
  let category = 'Main Course';
  let calories = 420;
  let protein = 18;
  let carbs = 45;
  let fat = 12;

  if (
    lowerText.includes('chicken') ||
    lowerText.includes('meat') ||
    lowerText.includes('lamb') ||
    lowerText.includes('mutton') ||
    lowerText.includes('beef') ||
    lowerText.includes('fish') ||
    lowerText.includes('prawn') ||
    lowerText.includes('shrimp')
  ) {
    dietaryType = 'Non-Vegetarian';
    calories = 520;
    protein = 42;
    carbs = 28;
    fat = 18;
  } else if (lowerText.includes('egg')) {
    dietaryType = 'Eggitarian';
    calories = 360;
    protein = 26;
    carbs = 20;
    fat = 14;
  } else if (lowerText.includes('paneer') || lowerText.includes('soya') || lowerText.includes('dal') || lowerText.includes('chana') || lowerText.includes('chickpea')) {
    dietaryType = 'Vegetarian';
    category = 'High Protein';
    calories = 440;
    protein = 28;
    carbs = 48;
    fat = 14;
  }

  if (lowerText.includes('biryani') || lowerText.includes('pulao') || lowerText.includes('rice')) {
    category = 'Rice & Biryani';
  } else if (lowerText.includes('dal') || lowerText.includes('curry') || lowerText.includes('masala')) {
    category = 'Curries & Dals';
  } else if (lowerText.includes('dosa') || lowerText.includes('idli') || lowerText.includes('poha') || lowerText.includes('oats')) {
    category = 'Breakfast';
  }

  return {
    id: `mealdb_${meal.idMeal}`,
    title: meal.strMeal,
    name: meal.strMeal,
    cuisine: 'North Indian',
    dietaryType,
    category,
    prepTimeMinutes: 15,
    cookTimeMinutes: 25,
    totalTime: '40 mins',
    servings: 2,
    difficulty: 'Intermediate',
    rating: 4.9,
    calories,
    protein,
    carbs,
    fat,
    fiber: 6,
    imageUrl: meal.strMealThumb || '',
    thumbnailUrl: meal.strMealThumb || '',
    youtubeUrl: meal.strYoutube || '',
    ingredients,
    ingredientList,
    steps: steps.length > 0 ? steps : [rawInstructions],
    instructions: rawInstructions,
    chefTips: 'Authentic Indian spice blend with roasted cumin and fresh coriander.',
    tags: [meal.strCategory || 'Indian', dietaryType, 'Traditional Flavor'],
    source: 'TheMealDB_Indian',
    isVerified: true,
    isActive: true,
  };
}

// 1. GET ALL RECIPES
exports.getAllRecipes = async (req, res) => {
  try {
    const { search, category, cuisine, dietaryType, difficulty, limit, page, sort } = req.query;
    const filter = {};

    if (category && category !== 'All Recipes' && category !== 'All') {
      filter.category = new RegExp(`^${category}$`, 'i');
    }

    if (cuisine && cuisine !== 'All Cuisines' && cuisine !== 'All') {
      filter.cuisine = new RegExp(`^${cuisine}$`, 'i');
    }

    if (dietaryType && dietaryType !== 'All' && dietaryType !== 'All Diets') {
      filter.dietaryType = new RegExp(`^${dietaryType}$`, 'i');
    }

    if (difficulty && difficulty !== 'All') {
      filter.difficulty = new RegExp(`^${difficulty}$`, 'i');
    }

    if (search && search.trim()) {
      const s = search.trim();
      const searchRegex = new RegExp(s, 'i');
      filter.$or = [
        { title: searchRegex },
        { name: searchRegex },
        { cuisine: searchRegex },
        { category: searchRegex },
        { ingredientList: searchRegex },
        { chefTips: searchRegex },
      ];
    }

    let sortOption = { sortOrder: 1, rating: -1, createdAt: -1 };
    if (sort === 'calories_asc') sortOption = { calories: 1 };
    else if (sort === 'calories_desc') sortOption = { calories: -1 };
    else if (sort === 'protein_desc') sortOption = { protein: -1 };
    else if (sort === 'prep_asc') sortOption = { prepTimeMinutes: 1 };

    let query = Recipe.find(filter).sort(sortOption);

    if (limit && parseInt(limit) > 0) {
      const p = parseInt(page) || 1;
      const l = parseInt(limit);
      query = query.skip((p - 1) * l).limit(l);
    }

    const [recipes, totalCount] = await Promise.all([
      query.lean(),
      Recipe.countDocuments(filter),
    ]);

    res.json({
      success: true,
      totalCount,
      count: recipes.length,
      page: parseInt(page) || 1,
      data: recipes,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 2. GET RECIPE BY ID
exports.getRecipeById = async (req, res) => {
  try {
    const { id } = req.params;
    let recipe = await Recipe.findOne({ id });

    if (!recipe && id.startsWith('mealdb_')) {
      const mealId = id.replace('mealdb_', '');
      try {
        const mealData = await fetchJson(`https://www.themealdb.com/api/json/v1/1/lookup.php?i=${mealId}`);
        if (mealData?.meals?.length > 0) {
          const mapped = mapMealDbToNeuroFit(mealData.meals[0]);
          return res.json({ success: true, data: mapped });
        }
      } catch (e) {
        // Fall through
      }
    }

    if (!recipe) {
      return res.status(404).json({ success: false, message: 'Recipe not found' });
    }

    res.json({ success: true, data: recipe });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 3. SEARCH LIVE INDIAN RECIPES API
exports.searchIndianRecipesLive = async (req, res) => {
  try {
    const query = (req.query.query || req.query.q || '').trim();
    const fullMeals = [];
    const seenTitles = new Set();

    const qLower = query.toLowerCase().replace(/[^a-z0-9]/g, '_');
    for (const [key, dish] of Object.entries(indianKnownDishes)) {
      if (
        !query ||
        key.includes(qLower) ||
        qLower.includes(key) ||
        dish.title.toLowerCase().includes(query.toLowerCase()) ||
        dish.cuisine.toLowerCase().includes(query.toLowerCase()) ||
        dish.category.toLowerCase().includes(query.toLowerCase()) ||
        (dish.ingredientList && dish.ingredientList.some((i) => i.toLowerCase().includes(query.toLowerCase())))
      ) {
        if (!seenTitles.has(dish.title.toLowerCase())) {
          seenTitles.add(dish.title.toLowerCase());
          fullMeals.push({
            id: `live_ind_${key}`,
            ...dish,
            name: dish.name || dish.title,
            servings: dish.servings || 2,
            difficulty: dish.difficulty || 'Easy',
            rating: dish.rating || 4.9,
            source: 'IndianCurated_Live',
            isVerified: true,
            isActive: true,
          });
        }
      }
    }

    // Query TheMealDB Indian meals if needed
    if (query) {
      try {
        const data = await fetchJson(`https://www.themealdb.com/api/json/v1/1/search.php?s=${encodeURIComponent(query)}`, 2000);
        for (const m of (data?.meals || []).slice(0, 4)) {
          if (!seenTitles.has(m.strMeal.toLowerCase())) {
            seenTitles.add(m.strMeal.toLowerCase());
            fullMeals.push(mapMealDbToNeuroFit(m));
          }
        }
      } catch (e) {}
    }

    res.json({
      success: true,
      count: fullMeals.length,
      data: fullMeals,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 4. SEARCH USDA & GLOBAL HEALTHY RECIPES API
exports.searchUsdaRecipesLive = async (req, res) => {
  try {
    const query = (req.query.query || req.query.q || '').trim();
    const fullMeals = [];
    const seenTitles = new Set();

    const qLower = query.toLowerCase().replace(/[^a-z0-9]/g, '_');
    for (const [key, dish] of Object.entries(usdaHealthyRecipes)) {
      if (
        !query ||
        key.includes(qLower) ||
        qLower.includes(key) ||
        dish.title.toLowerCase().includes(query.toLowerCase()) ||
        dish.cuisine.toLowerCase().includes(query.toLowerCase()) ||
        dish.category.toLowerCase().includes(query.toLowerCase()) ||
        (dish.ingredientList && dish.ingredientList.some((i) => i.toLowerCase().includes(query.toLowerCase())))
      ) {
        if (!seenTitles.has(dish.title.toLowerCase())) {
          seenTitles.add(dish.title.toLowerCase());
          fullMeals.push({
            id: `live_usda_${key}`,
            ...dish,
            name: dish.name || dish.title,
            servings: dish.servings || 2,
            difficulty: dish.difficulty || 'Easy',
            rating: dish.rating || 4.9,
            source: 'USDA_HealthyMeals',
            isVerified: true,
            isActive: true,
          });
        }
      }
    }

    res.json({
      success: true,
      count: fullMeals.length,
      data: fullMeals,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 5. SEARCH THEMEALDB GLOBAL RECIPES API
exports.searchMealDbRecipesLive = async (req, res) => {
  try {
    const query = (req.query.query || req.query.q || '').trim();
    const fullMeals = [];
    const seenTitles = new Set();

    const searchUrl = query
      ? `https://www.themealdb.com/api/json/v1/1/search.php?s=${encodeURIComponent(query)}`
      : 'https://www.themealdb.com/api/json/v1/1/search.php?s=chicken';

    const data = await fetchJson(searchUrl, 2500);
    const meals = data?.meals || [];
    for (const m of meals.slice(0, 10)) {
      if (!seenTitles.has(m.strMeal.toLowerCase())) {
        seenTitles.add(m.strMeal.toLowerCase());
        fullMeals.push(mapMealDbToNeuroFit(m));
      }
    }

    res.json({
      success: true,
      count: fullMeals.length,
      data: fullMeals,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 6. UNIFIED MULTI-SOURCE RECIPE SEARCH (Indian + USDA + TheMealDB)
exports.searchLiveRecipes = async (req, res) => {
  try {
    const query = (req.query.query || req.query.q || '').trim();
    const source = (req.query.source || 'all').toLowerCase(); // 'all', 'indian', 'usda', 'mealdb'
    const fullMeals = [];
    const seenTitles = new Set();

    // 1. Indian Curated Recipes
    if (source === 'all' || source === 'indian') {
      const qLower = query.toLowerCase().replace(/[^a-z0-9]/g, '_');
      for (const [key, dish] of Object.entries(indianKnownDishes)) {
        if (
          !query ||
          key.includes(qLower) ||
          qLower.includes(key) ||
          dish.title.toLowerCase().includes(query.toLowerCase()) ||
          dish.cuisine.toLowerCase().includes(query.toLowerCase()) ||
          dish.category.toLowerCase().includes(query.toLowerCase()) ||
          (dish.ingredientList && dish.ingredientList.some((i) => i.toLowerCase().includes(query.toLowerCase())))
        ) {
          if (!seenTitles.has(dish.title.toLowerCase())) {
            seenTitles.add(dish.title.toLowerCase());
            fullMeals.push({
              id: `live_ind_${key}`,
              ...dish,
              name: dish.name || dish.title,
              servings: dish.servings || 2,
              difficulty: dish.difficulty || 'Easy',
              rating: dish.rating || 4.9,
              source: 'IndianCurated_Live',
              isVerified: true,
              isActive: true,
            });
          }
        }
      }
    }

    // 2. USDA Healthy Meals
    if (source === 'all' || source === 'usda') {
      const qLower = query.toLowerCase().replace(/[^a-z0-9]/g, '_');
      for (const [key, dish] of Object.entries(usdaHealthyRecipes)) {
        if (
          !query ||
          key.includes(qLower) ||
          qLower.includes(key) ||
          dish.title.toLowerCase().includes(query.toLowerCase()) ||
          dish.cuisine.toLowerCase().includes(query.toLowerCase()) ||
          dish.category.toLowerCase().includes(query.toLowerCase()) ||
          (dish.ingredientList && dish.ingredientList.some((i) => i.toLowerCase().includes(query.toLowerCase())))
        ) {
          if (!seenTitles.has(dish.title.toLowerCase())) {
            seenTitles.add(dish.title.toLowerCase());
            fullMeals.push({
              id: `live_usda_${key}`,
              ...dish,
              name: dish.name || dish.title,
              servings: dish.servings || 2,
              difficulty: dish.difficulty || 'Easy',
              rating: dish.rating || 4.9,
              source: 'USDA_HealthyMeals',
              isVerified: true,
              isActive: true,
            });
          }
        }
      }
    }

    // 3. TheMealDB Live API
    if (source === 'all' || source === 'mealdb' || (source === 'indian' && query)) {
      try {
        let url = 'https://www.themealdb.com/api/json/v1/1/filter.php?a=Indian';
        if (source === 'mealdb' && !query) {
          url = 'https://www.themealdb.com/api/json/v1/1/search.php?s=chicken';
        } else if (query) {
          url = `https://www.themealdb.com/api/json/v1/1/search.php?s=${encodeURIComponent(query)}`;
        }

        const data = await fetchJson(url, 2500);
        const meals = data?.meals || [];
        if (meals.length > 0) {
          const needDetail = [];
          for (const m of meals.slice(0, 8)) {
            if (m.strInstructions) {
              if (!seenTitles.has(m.strMeal.toLowerCase())) {
                seenTitles.add(m.strMeal.toLowerCase());
                fullMeals.push(mapMealDbToNeuroFit(m));
              }
            } else {
              needDetail.push(m.idMeal);
            }
          }

          if (needDetail.length > 0) {
            const detailPromises = needDetail.slice(0, 4).map((id) =>
              fetchJson(`https://www.themealdb.com/api/json/v1/1/lookup.php?i=${id}`, 2000)
            );
            const results = await Promise.allSettled(detailPromises);
            for (const res of results) {
              if (res.status === 'fulfilled' && res.value?.meals?.length > 0) {
                const meal = res.value.meals[0];
                if (!seenTitles.has(meal.strMeal.toLowerCase())) {
                  seenTitles.add(meal.strMeal.toLowerCase());
                  fullMeals.push(mapMealDbToNeuroFit(meal));
                }
              }
            }
          }
        }
      } catch (e) {}
    }

    res.json({
      success: true,
      count: fullMeals.length,
      data: fullMeals,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 4. CREATE RECIPE
exports.createRecipe = async (req, res) => {
  try {
    const payload = req.body;
    if (!payload.id) {
      payload.id = `rec_${Date.now()}`;
    }

    if (payload.ingredients && !payload.ingredientList) {
      payload.ingredientList = payload.ingredients.map(
        (i) => `${i.quantity ? i.quantity + ' ' : ''}${i.name}`
      );
    }

    const recipe = await Recipe.create(payload);

    const io = req.app.get('socketio') || req.io;
    if (io) {
      io.emit('recipe_created', recipe);
    }

    res.status(201).json({ success: true, data: recipe });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 5. UPDATE RECIPE
exports.updateRecipe = async (req, res) => {
  try {
    const { id } = req.params;
    const recipe = await Recipe.findOneAndUpdate(
      { $or: [{ id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }] },
      { $set: req.body },
      { new: true }
    );

    if (!recipe) {
      return res.status(404).json({ success: false, message: 'Recipe not found' });
    }

    const io = req.app.get('socketio') || req.io;
    if (io) {
      io.emit('recipe_updated', recipe);
    }

    res.json({ success: true, data: recipe });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 6. DELETE RECIPE
exports.deleteRecipe = async (req, res) => {
  try {
    const { id } = req.params;
    const recipe = await Recipe.findOneAndDelete({
      $or: [{ id }, { _id: id.match(/^[0-9a-fA-F]{24}$/) ? id : null }],
    });

    if (!recipe) {
      return res.status(404).json({ success: false, message: 'Recipe not found' });
    }

    const io = req.app.get('socketio') || req.io;
    if (io) {
      io.emit('recipe_deleted', { id: recipe.id });
    }

    res.json({ success: true, message: 'Recipe deleted successfully', id: recipe.id });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// 7. GET DAILY ROTATING FEATURED RECIPES (100% Free APIs, Cached in MongoDB for 24h)
exports.getDailyFeaturedRecipes = async (req, res) => {
  try {
    const now = new Date();
    const dateKey = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;

    // 1. Check if today's rotation is already cached in MongoDB
    let cachedDaily = await DailyFeaturedRecipe.findOne({ dateKey });
    if (cachedDaily && cachedDaily.recipes && cachedDaily.recipes.length > 0) {
      return res.status(200).json({
        success: true,
        dateKey,
        isNewRotation: false,
        recipes: cachedDaily.recipes,
      });
    }

    // 2. Not cached or new day -> Pick fresh randomized selection from 100% free APIs
    const candidatePool = [];

    // Add USDA Healthy Fitness Meals
    if (Array.isArray(usdaHealthyRecipes)) {
      for (const r of usdaHealthyRecipes) {
        candidatePool.push({
          id: r.id || `usda_${Math.random().toString(36).substr(2, 6)}`,
          title: r.title,
          source: 'USDA_HealthyMeals',
          category: r.category || 'High Protein',
          calories: r.calories || 380,
          protein: r.protein || 35,
          carbs: r.carbs || 30,
          fats: r.fat || r.fats || 12,
          fiber: r.fiber || 6,
          prepTimeMinutes: r.prepTimeMinutes || 15,
          cookTimeMinutes: r.cookTimeMinutes || 20,
          servings: r.servings || 2,
          difficulty: r.difficulty || 'Easy',
          imageUrl: r.imageUrl || '',
          instructions: Array.isArray(r.steps) ? r.steps : (Array.isArray(r.instructions) ? r.instructions : []),
          ingredients: Array.isArray(r.ingredientList) ? r.ingredientList : (Array.isArray(r.ingredients) ? r.ingredients.map(i => typeof i === 'string' ? i : `${i.quantity || ''} ${i.unit || ''} ${i.name || ''}`.trim()) : []),
          tags: r.tags || ['USDA Guidelines', 'High Protein'],
          tips: r.chefTips || r.tips || 'Optimal for lean muscle retention.',
        });
      }
    }

    // Add Authentic Indian Fitness Recipes
    for (const [slug, item] of Object.entries(indianKnownDishes)) {
      candidatePool.push({
        id: `ind_${slug}`,
        title: item.title,
        source: 'IndianCurated_Live',
        category: item.category || 'Indian Traditional',
        calories: item.calories || 320,
        protein: item.protein || 18,
        carbs: item.carbs || 40,
        fats: item.fat || item.fats || 10,
        fiber: item.fiber || 8,
        prepTimeMinutes: item.prepTimeMinutes || 15,
        cookTimeMinutes: item.cookTimeMinutes || 20,
        servings: 2,
        difficulty: 'Easy',
        imageUrl: item.imageUrl || '',
        instructions: item.steps || [],
        ingredients: item.ingredientList || [],
        tags: item.tags || ['Indian Traditional', 'Rich Flavor'],
        tips: item.chefTips || 'Slow cook with fresh herbs for maximum aroma.',
      });
    }

    // Shuffle candidate pool with Fisher-Yates
    for (let i = candidatePool.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [candidatePool[i], candidatePool[j]] = [candidatePool[j], candidatePool[i]];
    }

    // Select 8 rotating items
    const selectedRecipes = candidatePool.slice(0, 8);

    // Save to MongoDB for 24-hour retention
    try {
      await DailyFeaturedRecipe.findOneAndUpdate(
        { dateKey },
        { $set: { dateKey, recipes: selectedRecipes } },
        { upsert: true, new: true }
      );
    } catch (saveErr) {
      console.warn('Could not cache daily recipes to MongoDB:', saveErr.message);
    }

    res.status(200).json({
      success: true,
      dateKey,
      isNewRotation: true,
      recipes: selectedRecipes,
    });
  } catch (error) {
    console.error('Error in getDailyFeaturedRecipes:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

