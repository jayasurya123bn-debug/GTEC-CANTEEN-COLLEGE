import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';
import logger from '../utils/logger.js';

dotenv.config();

let ioInstance;

export const setupSocket = (io) => {
  ioInstance = io;

  // Authentication Middleware
  io.use((socket, next) => {
    const token = socket.handshake.auth.token || socket.handshake.headers['authorization'];
    if (!token) {
      return next(new Error('Authentication error: Token missing'));
    }

    const actualToken = token.startsWith('Bearer ') ? token.split(' ')[1] : token;

    jwt.verify(actualToken, process.env.JWT_SECRET || 'fallback_super_secret_key_123', (err, decoded) => {
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

// ─── Pre-Order Event Emitters ───────────────────────────────────────────────

/**
 * Emit when a menu item hits 100% pre-order capacity.
 * All clients update the item's badge to "Sold Out".
 */
export const emitSoldOut = (itemId, itemName, mealSlot) => {
  try {
    const io = getIO();
    io.emit('pre_order:soldOut', { itemId, itemName, mealSlot });
    logger.info(`[Socket] pre_order:soldOut → itemId=${itemId}, slot=${mealSlot}`);
  } catch (err) {
    logger.warn('emitSoldOut failed (non-fatal):', err.message);
  }
};

/**
 * Emit when any pre-order changes capacity (add or cancel).
 * All clients update "Only X left" counters.
 */
export const emitCapacityUpdate = (itemId, remaining, status, mealSlot) => {
  try {
    const io = getIO();
    io.emit('pre_order:capacityUpdate', { itemId, remaining, status, mealSlot });
    logger.info(`[Socket] pre_order:capacityUpdate → itemId=${itemId}, remaining=${remaining}, status=${status}`);
  } catch (err) {
    logger.warn('emitCapacityUpdate failed (non-fatal):', err.message);
  }
};

/**
 * Emit when admin updates the "now serving" token number.
 * All Flutter clients update NowServingBanner prominently.
 */
export const emitNowServing = (tokenNumber, mealSlot) => {
  try {
    const io = getIO();
    io.emit('canteen:nowServing', {
      tokenNumber,
      mealSlot,
      timestamp: new Date().toISOString(),
    });
    logger.info(`[Socket] canteen:nowServing → token=#${tokenNumber}, slot=${mealSlot}`);
  } catch (err) {
    logger.warn('emitNowServing failed (non-fatal):', err.message);
  }
};

/**
 * Emit directly to the student who just placed a pre-order.
 * Flutter navigates to TokenReceiptScreen.
 */
export const emitTokenGenerated = (userId, orderId, tokenNumber, tokenStart, tokenEnd, mealSlot, estimatedWait) => {
  try {
    const io = getIO();
    io.to(`user:${userId}`).emit('order:tokenGenerated', {
      orderId,
      tokenNumber,
      tokenStart,
      tokenEnd,
      mealSlot,
      estimatedWait,
    });
    logger.info(`[Socket] order:tokenGenerated → user=${userId}, token=#${tokenEnd}`);
  } catch (err) {
    logger.warn('emitTokenGenerated failed (non-fatal):', err.message);
  }
};

/**
 * Emit order status update to all clients and the specific student.
 */
export const emitOrderStatusUpdate = (userId, orderId, status, tokenNumber) => {
  try {
    const io = getIO();
    const payload = { orderId, status, tokenNumber };
    io.emit('order:statusUpdate', payload);
    if (userId) {
      io.to(`user:${userId}`).emit('order:statusUpdate', payload);
    }
    logger.info(`[Socket] order:statusUpdate → orderId=${orderId}, status=${status}`);
  } catch (err) {
    logger.warn('emitOrderStatusUpdate failed (non-fatal):', err.message);
  }
};
