const dotenv = require('dotenv');
dotenv.config();

const express = require('express');
const http = require('http');
const { Server } = require('socket.io');
const cors = require('cors');
const connectDB = require('./config/db');
const firebaseAdmin = require('./config/firebaseAdmin');

connectDB();
require('./services/redisService');

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
  },
});

const path = require('path');

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use('/uploads', express.static(path.join(__dirname, 'public/uploads')));
app.use('/exercises', express.static(path.join(__dirname, 'public/exercises')));
app.use('/assets/exercises', express.static(path.join(__dirname, 'public/exercises')));

// Live Request Logger Middleware
app.use((req, res, next) => {
  const time = new Date().toLocaleTimeString();
  console.log(`[${time}] 📥 ${req.method} ${req.originalUrl}`);
  if ((req.method === 'POST' || req.method === 'PUT') && !req.originalUrl.includes('/media/upload')) {
    console.log('📦 Body:', JSON.stringify(req.body, null, 2));
  }
  next();
});

// ==============================================================================
// NEUROFIT EXPRESS BACKEND SERVER (Port 5000) - Push Notifications & DB Active
// ==============================================================================

// Pass socket.io instance to request
app.use((req, res, next) => {
  req.io = io;
  next();
});

io.on('connection', (socket) => {
  console.log(`🔌 Client connected to Socket.io: ${socket.id}`);

  socket.on('join_user_room', (uid) => {
    socket.join(`user_${uid}`);
    console.log(`👤 Socket ${socket.id} joined room: user_${uid}`);
  });

  socket.on('join_admin_room', () => {
    socket.join('admin_room');
    console.log(`🛡️ Admin Socket ${socket.id} joined room: admin_room`);
  });

  socket.on('disconnect', () => {
    console.log(`❌ Client disconnected: ${socket.id}`);
  });
});

// API Routes
app.use('/api/products', require('./routes/productRoutes'));
app.use('/api/categories', require('./routes/categoryRoutes'));
app.use('/api/banners', require('./routes/bannerRoutes'));
app.use('/api/layout', require('./routes/layoutRoutes'));
app.use('/api/orders', require('./routes/orderRoutes'));
app.use('/api/users', require('./routes/userRoutes'));
app.use('/api/notifications', require('./routes/notificationRoutes'));
app.use('/api/sync', require('./routes/syncRoutes'));
app.use('/api/admin', require('./routes/adminRoutes'));
app.use('/api/discounts', require('./routes/discountRoutes'));
app.use('/api/subcategories', require('./routes/subCategoryRoutes'));
app.use('/api/media', require('./routes/mediaRoutes'));
app.use('/api/workout-layout', require('./routes/workoutLayoutRoutes'));
app.use('/api/workouts', require('./routes/workoutRoutes'));
app.use('/api/programs', require('./routes/programRoutes'));
app.use('/api/exercises', require('./routes/exerciseRoutes'));
app.use('/api/workout-categories', require('./routes/workoutCategoryRoutes'));
app.use('/api/workout-banners', require('./routes/workoutBannerRoutes'));
app.use('/api/exercise-categories', require('./routes/exerciseCategoryRoutes'));
app.use('/api/foods', require('./routes/foodRoutes'));
app.use('/api/recipes', require('./routes/recipeRoutes'));
app.use('/api/user-workouts', require('./routes/userWorkoutRoutes'));
app.use('/api/user-nutrition', require('./routes/userNutritionRoutes'));

app.get('/', (req, res) => {
  res.send('⚡ NeuroFit Real-Time Express + Socket.io Backend API with MongoDB Atlas is Live!');
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Real-Time NeuroFit Server listening on port ${PORT} (0.0.0.0 - All Network Interfaces)`);
});
