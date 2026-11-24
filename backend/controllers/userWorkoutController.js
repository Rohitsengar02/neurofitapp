const UserWorkout = require('../models/UserWorkout');

// 1. Start or resume a workout day session
exports.startUserWorkout = async (req, res) => {
  try {
    const {
      uid,
      workoutId,
      workoutTitle = 'Workout Session',
      dayNumber = 1,
      weekNumber = 1,
      exercises = [],
      totalExercisesCount = 0,
    } = req.body;

    if (!uid || !workoutId) {
      return res.status(400).json({ success: false, message: 'uid and workoutId are required' });
    }

    let userWorkout = await UserWorkout.findOne({ uid, workoutId, dayNumber });

    if (!userWorkout) {
      const initialProgress = exercises.map((e, idx) => ({
        exerciseId: (e.exerciseId || e.id || `ex_${idx + 1}`).toString(),
        exerciseTitle: (e.title || e.name || `Exercise ${idx + 1}`).toString(),
        completedSets: 0,
        totalSets: Number(e.sets) || 3,
        isCompleted: false,
      }));

      userWorkout = new UserWorkout({
        uid,
        workoutId,
        workoutTitle,
        dayNumber,
        weekNumber,
        status: 'in_progress',
        startedAt: new Date(),
        lastActiveAt: new Date(),
        totalDurationSeconds: 0,
        currentExerciseIndex: 0,
        currentSetIndex: 0,
        completedExercises: [],
        exercisesProgress: initialProgress,
        dayCompleted: false,
        totalExercisesCount: totalExercisesCount || exercises.length,
      });

      await userWorkout.save();
    } else {
      if (userWorkout.status === 'not_started') {
        userWorkout.status = 'in_progress';
        userWorkout.startedAt = new Date();
      }
      userWorkout.lastActiveAt = new Date();
      await userWorkout.save();
    }

    // Real-time socket broadcast
    if (req.io) {
      req.io.to(`user_${uid}`).emit('user_workout_started', {
        uid,
        workoutId,
        dayNumber,
        userWorkout,
      });
    }

    res.status(200).json({ success: true, userWorkout });
  } catch (error) {
    console.error('Error in startUserWorkout:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 2. Update real-time progress (set completed, step moved, timer tick)
exports.updateWorkoutProgress = async (req, res) => {
  try {
    const {
      uid,
      workoutId,
      dayNumber = 1,
      currentExerciseIndex,
      currentSetIndex,
      completedExerciseId,
      isExerciseCompleted,
      totalDurationSeconds,
      dayCompleted,
    } = req.body;

    if (!uid || !workoutId) {
      return res.status(400).json({ success: false, message: 'uid and workoutId are required' });
    }

    let userWorkout = await UserWorkout.findOne({ uid, workoutId, dayNumber });

    if (!userWorkout) {
      userWorkout = new UserWorkout({
        uid,
        workoutId,
        dayNumber,
        status: dayCompleted ? 'completed' : 'in_progress',
        startedAt: new Date(),
        lastActiveAt: new Date(),
      });
    }

    if (currentExerciseIndex !== undefined) {
      userWorkout.currentExerciseIndex = Number(currentExerciseIndex);
    }
    if (currentSetIndex !== undefined) {
      userWorkout.currentSetIndex = Number(currentSetIndex);
    }
    if (totalDurationSeconds !== undefined) {
      userWorkout.totalDurationSeconds = Number(totalDurationSeconds);
    }

    if (completedExerciseId) {
      const exIdStr = completedExerciseId.toString();
      if (isExerciseCompleted !== false) {
        if (!userWorkout.completedExercises.includes(exIdStr)) {
          userWorkout.completedExercises.push(exIdStr);
        }
      } else {
        userWorkout.completedExercises = userWorkout.completedExercises.filter(
          (id) => id !== exIdStr
        );
      }
    }

    if (dayCompleted === true) {
      userWorkout.status = 'completed';
      userWorkout.dayCompleted = true;
      userWorkout.completedAt = new Date();
    } else if (userWorkout.status === 'not_started') {
      userWorkout.status = 'in_progress';
    }

    userWorkout.lastActiveAt = new Date();
    await userWorkout.save();

    // Real-time socket broadcast
    if (req.io) {
      req.io.to(`user_${uid}`).emit('user_workout_progress_updated', {
        uid,
        workoutId,
        dayNumber,
        userWorkout,
      });
    }

    res.status(200).json({ success: true, userWorkout });
  } catch (error) {
    console.error('Error in updateWorkoutProgress:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 3. Get workout progress for a specific day
exports.getUserWorkoutProgress = async (req, res) => {
  try {
    const { uid, workoutId, dayNumber } = req.params;

    const userWorkout = await UserWorkout.findOne({
      uid,
      workoutId,
      dayNumber: Number(dayNumber),
    });

    if (!userWorkout) {
      return res.status(200).json({
        success: true,
        userWorkout: {
          uid,
          workoutId,
          dayNumber: Number(dayNumber),
          status: 'not_started',
          currentExerciseIndex: 0,
          currentSetIndex: 0,
          completedExercises: [],
          dayCompleted: false,
          totalDurationSeconds: 0,
        },
      });
    }

    res.status(200).json({ success: true, userWorkout });
  } catch (error) {
    console.error('Error in getUserWorkoutProgress:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 4. Get all workout history for a user
exports.getUserAllWorkouts = async (req, res) => {
  try {
    const { uid } = req.params;
    const userWorkouts = await UserWorkout.find({ uid }).sort({ updatedAt: -1 });
    res.status(200).json({ success: true, userWorkouts });
  } catch (error) {
    console.error('Error in getUserAllWorkouts:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};

// 5. Reset progress for a day (start over)
exports.resetUserWorkout = async (req, res) => {
  try {
    const { uid, workoutId, dayNumber = 1 } = req.body;

    if (!uid || !workoutId) {
      return res.status(400).json({ success: false, message: 'uid and workoutId are required' });
    }

    let userWorkout = await UserWorkout.findOne({ uid, workoutId, dayNumber });

    if (userWorkout) {
      userWorkout.status = 'not_started';
      userWorkout.currentExerciseIndex = 0;
      userWorkout.currentSetIndex = 0;
      userWorkout.completedExercises = [];
      userWorkout.dayCompleted = false;
      userWorkout.totalDurationSeconds = 0;
      userWorkout.completedAt = null;
      userWorkout.lastActiveAt = new Date();
      await userWorkout.save();
    } else {
      userWorkout = new UserWorkout({
        uid,
        workoutId,
        dayNumber,
        status: 'not_started',
        currentExerciseIndex: 0,
        currentSetIndex: 0,
        completedExercises: [],
        dayCompleted: false,
        totalDurationSeconds: 0,
      });
      await userWorkout.save();
    }

    // Real-time socket broadcast
    if (req.io) {
      req.io.to(`user_${uid}`).emit('user_workout_reset', {
        uid,
        workoutId,
        dayNumber,
        userWorkout,
      });
    }

    res.status(200).json({ success: true, userWorkout });
  } catch (error) {
    console.error('Error in resetUserWorkout:', error);
    res.status(500).json({ success: false, message: error.message });
  }
};
