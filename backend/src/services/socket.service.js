import { createAdapter } from '@socket.io/redis-adapter';
import redisClient from '../config/redis.js';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import logger from '../utils/logger.js';

dotenv.config();

let ioInstance;

export const setupSocket = (io) => {
  ioInstance = io;
  const subClient = redisClient.duplicate();
  io.adapter(createAdapter(redisClient, subClient));

  // Authentication Middleware
  io.use((socket, next) => {
    const token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
    if (!token) {
      return next(new Error('Authentication error: Token missing'));
    }

    const actualToken = token.startsWith('Bearer ') ? token.split(' ')[1] : token;

    jwt.verify(actualToken, process.env.JWT_SECRET, (err, decoded) => {
      if (err) {
        return next(new Error('Authentication error: Invalid token'));
      }
      socket.user = decoded;
      next();
    });
  });

  io.on('connection', (socket) => {
    logger.info(`User connected: ${socket.user.id}`);
    
    // Join personal room
    socket.join(`user:${socket.user.id}`);

    // If admin, join admin room
    if (socket.user.role === 'admin') {
      socket.join('admins');
      logger.info(`Admin joined admins room: ${socket.user.id}`);
    }

    socket.on('disconnect', () => {
      logger.info(`User disconnected: ${socket.user.id}`);
    });
  });
};

export const getIO = () => {
  if (!ioInstance) {
    throw new Error('Socket.io not initialized!');
  }
  return ioInstance;
};
