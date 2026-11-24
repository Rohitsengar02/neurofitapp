const fs = require('fs');
const path = require('path');
const dotenv = require('dotenv');
dotenv.config({ path: path.join(__dirname, '../.env') });
const mongoose = require('mongoose');
const Exercise = require('../models/Exercise');
const ExerciseCategory = require('../models/ExerciseCategory');

async function seedExercises() {
  try {
    console.log('🔗 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB.');

    const datasetPath = path.join(__dirname, '../../exercises-dataset/data/exercises.json');
    if (!fs.existsSync(datasetPath)) {
      console.error('❌ exercises.json not found at:', datasetPath);
      process.exit(1);
    }

    console.log('📖 Reading exercises.json...');
    const rawData = fs.readFileSync(datasetPath, 'utf8');
    const exercisesArray = JSON.parse(rawData);
    console.log(`📊 Found ${exercisesArray.length} exercises in dataset.`);

    const categoryMap = new Map();
    const exerciseDocs = [];

    // Helper to capitalize words
    const capitalize = (str) => {
      if (!str) return '';
      return str
        .split(' ')
        .map((w) => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase())
        .join(' ');
    };

    for (let i = 0; i < exercisesArray.length; i++) {
      const item = exercisesArray[i];

      // Format clean category name (e.g. "waist" -> "Waist & Abs", "chest" -> "Chest", etc.)
      const rawCategory = (item.category || item.body_part || 'General').toLowerCase();
      const catDisplayName = capitalize(rawCategory);

      if (!categoryMap.has(rawCategory)) {
        categoryMap.set(rawCategory, {
          id: `cat_${rawCategory.replace(/\s+/g, '_')}`,
          name: catDisplayName,
          rawCategory: rawCategory,
          count: 0,
          sampleImage: item.image ? `assets/exercises/${item.image}` : '',
        });
      }
      categoryMap.get(rawCategory).count++;

      // Instructions in English
      let instructionsArray = [];
      if (item.instruction_steps && item.instruction_steps.en && Array.isArray(item.instruction_steps.en)) {
        instructionsArray = item.instruction_steps.en;
      } else if (item.instructions && item.instructions.en) {
        instructionsArray = item.instructions.en.split(/\.\s+/).filter((s) => s.trim().length > 0);
      }

      const instructionText = (item.instructions && item.instructions.en) || instructionsArray.join('\n');

      const title = capitalize(item.name || `Exercise ${item.id}`);
      const mediaKey = item.image ? path.basename(item.image, path.extname(item.image)) : item.id;
      const imageUrl = item.image ? `assets/exercises/${item.image}` : '';
      const gifUrl = item.gif_url ? `assets/exercises/${item.gif_url}` : '';

      exerciseDocs.push({
        id: item.id || `ex_${i + 1}`,
        title: title,
        name: title,
        categoryId: `cat_${rawCategory.replace(/\s+/g, '_')}`,
        category: catDisplayName,
        bodyPart: capitalize(item.body_part || rawCategory),
        muscleGroup: capitalize(item.muscle_group || item.target || catDisplayName),
        target: capitalize(item.target || ''),
        secondaryMuscles: Array.isArray(item.secondary_muscles)
          ? item.secondary_muscles.map((m) => capitalize(m))
          : [],
        equipment: capitalize(item.equipment || 'body weight'),
        difficulty: i % 3 === 0 ? 'Beginner' : i % 3 === 1 ? 'Intermediate' : 'Advanced',
        sets: 3,
        reps: '10-12 reps',
        imageUrl: imageUrl,
        gifUrl: gifUrl,
        videoUrl: gifUrl,
        mediaType: gifUrl ? 'gif' : 'image',
        mediaId: item.media_id || '',
        mediaKey: mediaKey,
        instructions: instructionsArray,
        instructionText: instructionText,
        tips: `Focus on proper form, controlled tempo, and engage your ${item.target || 'target muscles'} throughout each repetition.`,
        sortOrder: i + 1,
        isActive: true,
      });
    }

    console.log(`🔄 Upserting ${exerciseDocs.length} exercises into MongoDB...`);

    // Use bulkWrite with upsert for speed and idempotency
    const bulkOps = exerciseDocs.map((doc) => ({
      updateOne: {
        filter: { id: doc.id },
        update: { $set: doc },
        upsert: true,
      },
    }));

    const result = await Exercise.bulkWrite(bulkOps);
    console.log(`✅ Upserted ${result.upsertedCount} new, modified ${result.modifiedCount} exercises.`);

    // Also seed Exercise Categories
    console.log('🔄 Seeding Exercise Categories...');
    for (const [key, cat] of categoryMap.entries()) {
      await ExerciseCategory.findOneAndUpdate(
        { $or: [{ categoryId: cat.id }, { name: cat.name }] },
        {
          $set: {
            categoryId: cat.id,
            name: cat.name,
            imageUrl: cat.sampleImage,
            description: `${cat.name} workout exercises and routines`,
            sortOrder: 1,
            isActive: true,
          },
        },
        { upsert: true, new: true }
      );
    }

    console.log(`✅ Seeded ${categoryMap.size} Exercise Categories:`);
    for (const cat of categoryMap.values()) {
      console.log(`   - ${cat.name} (${cat.count} exercises)`);
    }

    const totalInDb = await Exercise.countDocuments();
    console.log(`🎉 Total exercises now in DB: ${totalInDb}`);

    await mongoose.disconnect();
    console.log('🔌 Disconnected from DB. Seeding complete!');
  } catch (err) {
    console.error('❌ Error during exercise seeding:', err);
    process.exit(1);
  }
}

seedExercises();
