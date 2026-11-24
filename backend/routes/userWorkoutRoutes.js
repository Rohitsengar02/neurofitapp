const express = require('express');
const router = express.Router();
const userWorkoutController = require('../controllers/userWorkoutController');

router.post('/start', userWorkoutController.startUserWorkout);
router.post('/progress', userWorkoutController.updateWorkoutProgress);
router.get('/progress/:uid/:workoutId/:dayNumber', userWorkoutController.getUserWorkoutProgress);
router.get('/all/:uid', userWorkoutController.getUserAllWorkouts);
router.post('/reset', userWorkoutController.resetUserWorkout);

module.exports = router;
