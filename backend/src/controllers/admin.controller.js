import { getDashboardStats, getRecentOrders, getAllOrders, updateOrderStatus } from '../models/order.model.js';
import { getIO } from '../services/socket.service.js';
import { findUserById } from '../models/user.model.js';
import { sendPushNotification } from '../services/fcm.service.js';

export const getStats = async (req, res, next) => {
  try {
    const stats = await getDashboardStats();
    res.status(200).json(stats);
  } catch (error) {
    next(error);
  }
};

export const getRecentOrdersList = async (req, res, next) => {
  try {
    const orders = await getRecentOrders(10);
    res.status(200).json({ orders });
  } catch (error) {
    next(error);
  }
};

export const listAllOrders = async (req, res, next) => {
  try {
    const { status } = req.query;
    const orders = await getAllOrders({ status });
    res.status(200).json({ orders });
  } catch (error) {
    next(error);
  }
};

export const updateStatus = async (req, res, next) => {
  try {
    const { status } = req.body;
    const order = await updateOrderStatus(req.params.id, status);
    
    // Notify the user via socket
    getIO().to(`user:${order.user_id}`).emit('order:statusUpdate', {
      orderId: order.id,
      status: order.status,
      updatedAt: order.updated_at
    });

    // Notify user via FCM
    const user = await findUserById(order.user_id);
    if (user && user.fcm_token) {
      await sendPushNotification(
        user.fcm_token,
        'Order Update 🌿',
        `Your order #${order.id.slice(0,8)} is now ${status}!`,
        { type: 'order_update', orderId: order.id }
      );
    }
    
    res.status(200).json({ message: 'Order status updated', order });
  } catch (error) {
    next(error);
  }
};

export const getStudents = async (req, res, next) => {
  try {
    const { getAllStudents } = await import('../models/user.model.js');
    const students = await getAllStudents();
    res.status(200).json({ students });
  } catch (error) {
    next(error);
  }
};

export const deleteStudent = async (req, res, next) => {
  try {
    const { deleteUserById } = await import('../models/user.model.js');
    await deleteUserById(req.params.id);
    res.status(200).json({ message: 'Student deleted successfully' });
  } catch (error) {
    next(error);
  }
};


