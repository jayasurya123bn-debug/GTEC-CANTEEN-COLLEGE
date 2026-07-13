import express from 'express';
import http from 'http';
import cors from 'cors';
import helmet from 'helmet';
import dotenv from 'dotenv';
import { Server } from 'socket.io';
import logger from './src/utils/logger.js';
import { setupSocket } from './src/services/socket.service.js';

// Load env vars
dotenv.config();

import { query } from './src/config/database.js';
import bcrypt from 'bcryptjs';

const app = express();

// Automatically create the default admin account on server start
bcrypt.genSalt(12).then(salt => bcrypt.hash('admin123', salt)).then(hashed => {
  return query(
    `INSERT INTO users (name, email, password_hash, phone, role) 
     VALUES ('admin', 'admin@admin.com', $1, '0000000000', 'admin') 
     ON CONFLICT (email) DO UPDATE SET password_hash = $1, role = 'admin'`, 
    [hashed]
  );
})
.then(() => logger.info('✅ Created default admin account (email: admin, password: admin123)'))
.catch(err => logger.error('Failed to create admin:', err));
const server = http.createServer(app);

// Security Middlewares
app.use(helmet());
app.use(cors({
  origin: '*', // For demo purposes. In production, whitelist Flutter app and Admin Web domains
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
}));
app.use(express.json());

// Socket.IO setup
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

// Setup Socket.IO with Redis and Events
setupSocket(io);

// Health Check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', message: 'GTEC Pure Veg Canteen Server is running' });
});

// Routes will be mounted here
import authRoutes from './src/routes/auth.routes.js';
import canteenRoutes from './src/routes/canteenStatus.routes.js';
import menuRoutes from './src/routes/menu.routes.js';
import reviewRoutes from './src/routes/review.routes.js';
import favouriteRoutes from './src/routes/favourite.routes.js';
import orderRoutes from './src/routes/order.routes.js';
import notificationRoutes from './src/routes/notification.routes.js';
import adminRoutes from './src/routes/admin.routes.js';

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/canteen', canteenRoutes);
app.use('/api/v1/menu', menuRoutes);
app.use('/api/v1/reviews', reviewRoutes);
app.use('/api/v1/favourites', favouriteRoutes);
app.use('/api/v1/orders', orderRoutes);
app.use('/api/v1/notifications', notificationRoutes);
app.use('/api/v1/admin', adminRoutes);

// Error Handling Middleware
app.use((err, req, res, next) => {
  logger.error(err.stack);
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error'
  });
});

const PORT = process.env.PORT || 4000;
server.listen(PORT, () => {
  logger.info(`Server running on port ${PORT}`);
});

export { app, io };
