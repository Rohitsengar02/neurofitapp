const mongoose = require('mongoose');
const dotenv = require('dotenv');
const path = require('path');
const Workout = require('../models/Workout');
const Exercise = require('../models/Exercise');

dotenv.config({ path: path.join(__dirname, '../.env') });

async function seedWorkouts() {
  try {
    const mongoUri = process.env.MONGO_URI || process.env.MONGODB_URI;
    if (!mongoUri) {
      console.error('MONGODB_URI missing in .env file');
      process.exit(1);
    }

    await mongoose.connect(mongoUri);
    console.log('Connected to MongoDB for seeding Workouts...');

    // Fetch sample exercises from the database to link directly
    const dbExercises = await Exercise.find({ isActive: true }).limit(20).lean();

    const sampleWorkouts = [
      {
        id: 'workout_sixpack_core',
        title: 'Six Pack Abs & Core Sculpt',
        subtitle: 'Obliques, Upper & Lower Core Hypertrophy',
        description: 'Sculpt steel core stability, ripped obliques, and defined 6-pack abdominal muscles in under 25 minutes.',
        workoutCategoryId: 'wcat_core_shred',
        category: 'Six Pack Core Shred',
        durationMinutes: 25,
        caloriesBurn: 320,
        level: 'All Levels',
        coach: 'Coach Maya',
        imageUrl: 'https://pub-2f9dfa009fb741278ffecf93798ef013.r2.dev/fitness_cms_1740994910000.jpg',
        mediaType: 'image',
        exercisesCount: 5,
        completionRate: 98.0,
        rating: 5.0,
        tags: ['Core', 'Abs', 'Obliques', 'Quick Workout', 'Bodyweight'],
        isFeatured: true,
        isActive: true,
        exercises: [
          {
            exerciseId: '0001',
            title: '3/4 Sit-up',
            categoryId: 'cat_waist',
            muscleGroup: 'Abs & Core',
            mediaUrl: 'assets/exercises/videos/0001-2gPfomN.gif',
            mediaType: 'gif',
            sets: 4,
            reps: 15,
            restSeconds: 30,
            instructions: '1. Lie flat on back with knees bent\n2. Curl torso upward to 45 degrees\n3. Squeeze abs at peak contraction\n4. Lower down with 3s negative'
          },
          {
            exerciseId: '0002',
            title: '45° Side Bend',
            categoryId: 'cat_waist',
            muscleGroup: 'Obliques',
            mediaUrl: 'assets/exercises/videos/0002-Hy9D21L.gif',
            mediaType: 'gif',
            sets: 3,
            reps: 15,
            restSeconds: 30,
            instructions: '1. Stand feet shoulder-width apart\n2. Slowly bend torso laterally\n3. Engage oblique to pull back to center\n4. Alternate sides'
          },
          {
            exerciseId: '0003',
            title: 'Air Bike Crunch',
            categoryId: 'cat_waist',
            muscleGroup: 'Upper & Lower Abs',
            mediaUrl: 'assets/exercises/videos/0003-1ZFqTDN.gif',
            mediaType: 'gif',
            sets: 4,
            reps: 20,
            restSeconds: 45,
            instructions: '1. Hands behind head, knees at 90°\n2. Touch opposite elbow to knee\n3. Pedal legs smoothly\n4. Maintain steady breathing'
          },
          {
            exerciseId: '0006',
            title: 'Alternate Heel Touchers',
            categoryId: 'cat_waist',
            muscleGroup: 'Obliques & Lower Abs',
            mediaUrl: 'assets/exercises/videos/0006-h8b8H4J.gif',
            mediaType: 'gif',
            sets: 3,
            reps: 20,
            restSeconds: 30,
            instructions: '1. Lie on back with knees bent\n2. Reach right hand to right heel\n3. Switch to left hand to left heel\n4. Keep shoulder blades off ground'
          },
          {
            exerciseId: '0011',
            title: 'Ankle Circles & Plank Hold',
            categoryId: 'cat_waist',
            muscleGroup: 'Core & Stability',
            mediaUrl: 'assets/exercises/videos/0011-L4B4iFq.gif',
            mediaType: 'gif',
            sets: 3,
            reps: 12,
            restSeconds: 45,
            instructions: '1. Maintain rigid plank position\n2. Rotate ankles slowly\n3. Keep glutes and core fully braced'
          }
        ],
        days: [
          {
            dayNumber: 1,
            weekNumber: 1,
            title: 'Upper Abs & Obliques Burnout',
            focus: 'Upper Abs & Core',
            durationMinutes: 25,
            caloriesBurn: 320,
            isRestDay: false,
            exercises: [
              {
                exerciseId: '0001',
                title: '3/4 Sit-up',
                categoryId: 'cat_waist',
                muscleGroup: 'Abs & Core',
                mediaUrl: 'assets/exercises/videos/0001-2gPfomN.gif',
                mediaType: 'gif',
                sets: 4,
                reps: 15,
                restSeconds: 30,
                instructions: '1. Lie flat on back with knees bent\n2. Curl torso upward to 45 degrees\n3. Squeeze abs at peak contraction\n4. Lower down with 3s negative'
              },
              {
                exerciseId: '0002',
                title: '45° Side Bend',
                categoryId: 'cat_waist',
                muscleGroup: 'Obliques',
                mediaUrl: 'assets/exercises/videos/0002-Hy9D21L.gif',
                mediaType: 'gif',
                sets: 3,
                reps: 15,
                restSeconds: 30,
                instructions: '1. Stand feet shoulder-width apart\n2. Slowly bend torso laterally\n3. Engage oblique to pull back to center\n4. Alternate sides'
              },
              {
                exerciseId: '0003',
                title: 'Air Bike Crunch',
                categoryId: 'cat_waist',
                muscleGroup: 'Upper & Lower Abs',
                mediaUrl: 'assets/exercises/videos/0003-1ZFqTDN.gif',
                mediaType: 'gif',
                sets: 4,
                reps: 20,
                restSeconds: 45,
                instructions: '1. Hands behind head, knees at 90°\n2. Touch opposite elbow to knee\n3. Pedal legs smoothly\n4. Maintain steady breathing'
              }
            ]
          },
          {
            dayNumber: 2,
            weekNumber: 1,
            title: 'Lower Abs & Kinetic Chain Flow',
            focus: 'Lower Core & Obliques',
            durationMinutes: 20,
            caloriesBurn: 280,
            isRestDay: false,
            exercises: [
              {
                exerciseId: '0006',
                title: 'Alternate Heel Touchers',
                categoryId: 'cat_waist',
                muscleGroup: 'Obliques & Lower Abs',
                mediaUrl: 'assets/exercises/videos/0006-h8b8H4J.gif',
                mediaType: 'gif',
                sets: 3,
                reps: 20,
                restSeconds: 30,
                instructions: '1. Lie on back with knees bent\n2. Reach right hand to right heel\n3. Switch to left hand to left heel\n4. Keep shoulder blades off ground'
              },
              {
                exerciseId: '0011',
                title: 'Ankle Circles & Plank Hold',
                categoryId: 'cat_waist',
                muscleGroup: 'Core & Stability',
                mediaUrl: 'assets/exercises/videos/0011-L4B4iFq.gif',
                mediaType: 'gif',
                sets: 3,
                reps: 12,
                restSeconds: 45,
                instructions: '1. Maintain rigid plank position\n2. Rotate ankles slowly\n3. Keep glutes and core fully braced'
              }
            ]
          }
        ]
      },
      {
        id: 'workout_chest_shred',
        title: 'Explosive Chest & Tricep Blast',
        subtitle: 'Mass Building & Upper Body Sculpting',
        description: 'Target upper chest, lower pectorals, front delts, and triceps with progressive heavy overload movements.',
        workoutCategoryId: 'wcat_muscle_mass',
        category: 'Muscle Mass & Hypertrophy',
        durationMinutes: 45,
        caloriesBurn: 420,
        level: 'Advanced',
        coach: 'Coach Alex',
        imageUrl: 'https://pub-2f9dfa009fb741278ffecf93798ef013.r2.dev/banner_spotlight_video.mp4',
        mediaType: 'video',
        exercisesCount: 5,
        completionRate: 94.0,
        rating: 4.9,
        tags: ['Muscle Mass', 'Chest', 'Triceps', 'Heavy Overload'],
        isFeatured: true,
        isActive: true,
        exercises: [
          {
            exerciseId: '0025',
            title: 'Barbell Bench Press',
            categoryId: 'cat_chest',
            muscleGroup: 'Pectorals & Front Delts',
            mediaUrl: 'assets/exercises/videos/0025-a1B2c3D.gif',
            mediaType: 'gif',
            sets: 4,
            reps: 10,
            restSeconds: 90,
            instructions: '1. Lie flat on bench with barbell over eyes\n2. Grip slightly wider than shoulder width\n3. Lower bar to mid chest with 3s negative\n4. Press upward exploding through pectorals'
          },
          {
            exerciseId: '0043',
            title: 'Incline Dumbbell Flyes',
            categoryId: 'cat_chest',
            muscleGroup: 'Upper Chest Squeeze',
            mediaUrl: 'assets/exercises/videos/0043-x9Y8z7W.gif',
            mediaType: 'gif',
            sets: 3,
            reps: 12,
            restSeconds: 60,
            instructions: '1. Set bench to 30-degree incline\n2. Hold dumbbells above chest\n3. Arc arms wide feeling deep stretch\n4. Squeeze upper pecs at peak'
          },
          {
            exerciseId: '0003',
            title: 'Air Bike Core Finisher',
            categoryId: 'cat_waist',
            muscleGroup: 'Core Conditioning',
            mediaUrl: 'assets/exercises/videos/0003-1ZFqTDN.gif',
            mediaType: 'gif',
            sets: 3,
            reps: 20,
            restSeconds: 30,
            instructions: '1. High intensity burnout\n2. Alternate elbow to opposite knee\n3. Max effort'
          }
        ],
        days: [
          {
            dayNumber: 1,
            weekNumber: 1,
            title: 'Heavy Compound Chest Overload',
            focus: 'Pectorals & Delts',
            durationMinutes: 45,
            caloriesBurn: 420,
            isRestDay: false,
            exercises: [
              {
                exerciseId: '0025',
                title: 'Barbell Bench Press',
                categoryId: 'cat_chest',
                muscleGroup: 'Pectorals & Front Delts',
                mediaUrl: 'assets/exercises/videos/0025-a1B2c3D.gif',
                mediaType: 'gif',
                sets: 4,
                reps: 10,
                restSeconds: 90,
                instructions: '1. Lie flat on bench with barbell over eyes\n2. Grip slightly wider than shoulder width\n3. Lower bar to mid chest with 3s negative\n4. Press upward exploding through pectorals'
              },
              {
                exerciseId: '0043',
                title: 'Incline Dumbbell Flyes',
                categoryId: 'cat_chest',
                muscleGroup: 'Upper Chest Squeeze',
                mediaUrl: 'assets/exercises/videos/0043-x9Y8z7W.gif',
                mediaType: 'gif',
                sets: 3,
                reps: 12,
                restSeconds: 60,
                instructions: '1. Set bench to 30-degree incline\n2. Hold dumbbells above chest\n3. Arc arms wide feeling deep stretch\n4. Squeeze upper pecs at peak'
              }
            ]
          }
        ]
      },
      {
        id: 'workout_leg_hypertrophy',
        title: 'Quads & Hamstrings Annihilation',
        subtitle: 'Lower Body Strength & Power',
        description: 'Build powerful legs with high-volume squats, lunges, hamstring curls, and calf raises.',
        workoutCategoryId: 'wcat_legs',
        category: 'Lower Body Strength',
        durationMinutes: 40,
        caloriesBurn: 460,
        level: 'Intermediate',
        coach: 'Coach Vikram',
        imageUrl: 'https://pub-2f9dfa009fb741278ffecf93798ef013.r2.dev/fitness_cms_1740994910000.jpg',
        mediaType: 'image',
        exercisesCount: 4,
        completionRate: 96.0,
        rating: 4.8,
        tags: ['Legs', 'Quads', 'Hamstrings', 'Lower Body'],
        isFeatured: true,
        isActive: true,
        exercises: [
          {
            exerciseId: '0001',
            title: '3/4 Sit-up Core Activator',
            categoryId: 'cat_waist',
            muscleGroup: 'Core Stability',
            mediaUrl: 'assets/exercises/videos/0001-2gPfomN.gif',
            mediaType: 'gif',
            sets: 3,
            reps: 15,
            restSeconds: 30,
            instructions: '1. Engage core before heavy compound leg lifts'
          },
          {
            exerciseId: '0002',
            title: '45° Side Bend Hip Mobility',
            categoryId: 'cat_waist',
            muscleGroup: 'Hips & Core',
            mediaUrl: 'assets/exercises/videos/0002-Hy9D21L.gif',
            mediaType: 'gif',
            sets: 3,
            reps: 12,
            restSeconds: 30,
            instructions: '1. Warm up hip flexors and lateral chain'
          }
        ],
        days: [
          {
            dayNumber: 1,
            weekNumber: 1,
            title: 'Heavy Squats & Quad Builder',
            focus: 'Quads & Glutes',
            durationMinutes: 40,
            caloriesBurn: 460,
            isRestDay: false,
            exercises: [
              {
                exerciseId: '0001',
                title: '3/4 Sit-up Core Activator',
                categoryId: 'cat_waist',
                muscleGroup: 'Core Stability',
                mediaUrl: 'assets/exercises/videos/0001-2gPfomN.gif',
                mediaType: 'gif',
                sets: 3,
                reps: 15,
                restSeconds: 30,
                instructions: '1. Engage core before heavy compound leg lifts'
              },
              {
                exerciseId: '0002',
                title: '45° Side Bend Hip Mobility',
                categoryId: 'cat_waist',
                muscleGroup: 'Hips & Core',
                mediaUrl: 'assets/exercises/videos/0002-Hy9D21L.gif',
                mediaType: 'gif',
                sets: 3,
                reps: 12,
                restSeconds: 30,
                instructions: '1. Warm up hip flexors and lateral chain'
              }
            ]
          }
        ]
      }
    ];

    for (const wData of sampleWorkouts) {
      await Workout.findOneAndUpdate({ id: wData.id }, wData, { upsert: true, new: true });
    }

    console.log('✅ Successfully seeded rich sample Workouts in MongoDB Atlas!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding Workouts:', error);
    process.exit(1);
  }
}

seedWorkouts();

