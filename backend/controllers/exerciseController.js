const Exercise = require('../models/Exercise');

exports.getAllExercises = async (req, res) => {
  try {
    const { search, category, muscleGroup, equipment, bodyPart, limit, page } = req.query;
    const filter = {};

    if (category && category !== 'All' && category !== 'All Categories') {
      filter.$or = [
        { category: new RegExp(`^${category}$`, 'i') },
        { categoryId: category },
        { bodyPart: new RegExp(`^${category}$`, 'i') },
      ];
    }

    if (muscleGroup && muscleGroup !== 'All') {
      filter.muscleGroup = new RegExp(muscleGroup, 'i');
    }

    if (bodyPart && bodyPart !== 'All') {
      filter.bodyPart = new RegExp(bodyPart, 'i');
    }

    if (equipment && equipment !== 'All') {
      filter.equipment = new RegExp(equipment, 'i');
    }

    if (search && search.trim()) {
      const s = search.trim();
      const searchRegex = new RegExp(s, 'i');
      filter.$or = [
        { title: searchRegex },
        { name: searchRegex },
        { category: searchRegex },
        { muscleGroup: searchRegex },
        { target: searchRegex },
        { equipment: searchRegex },
        { bodyPart: searchRegex },
      ];
    }

    let query = Exercise.find(filter).sort({ sortOrder: 1, id: 1 });

    if (limit && parseInt(limit) > 0) {
      const p = parseInt(page) || 1;
      const l = parseInt(limit);
      query = query.skip((p - 1) * l).limit(l);
    }

    const [exercises, totalCount] = await Promise.all([
      query.lean(),
      Exercise.countDocuments(filter),
    ]);

    res.json({
      success: true,
      totalCount,
      count: exercises.length,
      data: exercises,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.getExerciseById = async (req, res) => {
  try {
    const exercise = await Exercise.findOne({ id: req.params.id });
    if (!exercise) return res.status(404).json({ success: false, message: 'Exercise not found' });
    res.json({ success: true, data: exercise });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.createExercise = async (req, res) => {
  try {
    const payload = req.body;
    if (!payload.id) {
      payload.id = `ex_${Date.now()}`;
    }
    const exercise = await Exercise.create(payload);

    const io = req.app.get('socketio') || req.io;
    if (io) {
      io.emit('exercise_created', exercise);
    }

    res.status(201).json({ success: true, data: exercise });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.updateExercise = async (req, res) => {
  try {
    const exercise = await Exercise.findOneAndUpdate(
      { id: req.params.id },
      { $set: req.body },
      { new: true }
    );
    if (!exercise) return res.status(404).json({ success: false, message: 'Exercise not found' });

    const io = req.app.get('socketio') || req.io;
    if (io) {
      io.emit('exercise_updated', exercise);
    }

    res.json({ success: true, data: exercise });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

exports.deleteExercise = async (req, res) => {
  try {
    const exercise = await Exercise.findOneAndDelete({ id: req.params.id });
    if (!exercise) return res.status(404).json({ success: false, message: 'Exercise not found' });

    const io = req.app.get('socketio') || req.io;
    if (io) {
      io.emit('exercise_deleted', { id: req.params.id });
    }

    res.json({ success: true, message: 'Exercise deleted' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
