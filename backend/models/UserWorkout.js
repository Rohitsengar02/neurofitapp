const mongoose = require('mongoose');

const userExerciseProgressSchema = new mongoose.Schema({
  exerciseId: { type: String, default: '' },
  exerciseTitle: { type: String, default: '' },
  completedSets: { type: Number, default: 0 },
  totalSets: { type: Number, default: 3 },
  isCompleted: { type: Boolean, default: false },
  completedAt: { type: Date },
});

const userWorkoutSchema = new mongoose.Schema(
  {
    uid: { type: String, required: true, index: true },
    workoutId: { type: String, required: true, index: true },
    workoutTitle: { type: String, default: 'Workout Session' },
    dayNumber: { type: Number, required: true, default: 1 },
    weekNumber: { type: Number, default: 1 },
    status: {
      type: String,
      enum: ['not_started', 'in_progress', 'completed'],
      default: 'not_started',
      index: true,
    },
    startedAt: { type: Date, default: Date.now },
    completedAt: { type: Date },
    lastActiveAt: { type: Date, default: Date.now },
    totalDurationSeconds: { type: Number, default: 0 },
    currentExerciseIndex: { type: Number, default: 0 },
    currentSetIndex: { type: Number, default: 0 },
    completedExercises: [{ type: String }],
    exercisesProgress: [userExerciseProgressSchema],
    dayCompleted: { type: Boolean, default: false },
    totalExercisesCount: { type: Number, default: 0 },
  },
  {
    collection: 'users_workouts',
    timestamps: true,
  }
);

// Compound index for instant lookups by user, workout, and day
userWorkoutSchema.index({ uid: 1, workoutId: 1, dayNumber: 1 }, { unique: true });

module.exports = mongoose.model('UserWorkout', userWorkoutSchema);
