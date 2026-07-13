import { getStatus, updateStatus, updateBroadcast } from '../models/canteenStatus.model.js';
import { getIO } from '../services/socket.service.js';

export const getCanteenStatus = async (req, res, next) => {
  try {
    const status = await getStatus();
    res.status(200).json(status);
  } catch (error) {
    next(error);
  }
};

export const updateCanteenStatus = async (req, res, next) => {
  try {
    const { is_open, busyness } = req.body;
    const status = await updateStatus(is_open, busyness, req.user.id);
    
    // Emit to all clients
    getIO().emit('canteen:status', {
      isOpen: status.is_open,
      busyness: status.busyness,
      broadcastMessage: status.broadcast_message,
      updatedAt: status.updated_at
    });

    res.status(200).json({ status });
  } catch (error) {
    next(error);
  }
};

export const setBroadcast = async (req, res, next) => {
  try {
    const { broadcast_message } = req.body;
    const status = await updateBroadcast(broadcast_message, req.user.id);
    
    getIO().emit('canteen:status', {
      isOpen: status.is_open,
      busyness: status.busyness,
      broadcastMessage: status.broadcast_message,
      updatedAt: status.updated_at
    });

    // Also emit specific broadcast event
    if (broadcast_message) {
      getIO().emit('admin:broadcast', {
        message: broadcast_message,
        sentAt: new Date().toISOString()
      });
    }

    res.status(200).json({ status });
  } catch (error) {
    next(error);
  }
};
