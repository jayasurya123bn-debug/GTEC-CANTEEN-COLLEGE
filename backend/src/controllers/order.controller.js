import { createOrder as placeOrder, getOrdersByUser, getOrderById } from '../models/order.model.js';
import { getIO } from '../services/socket.service.js';
import { createNotification } from '../models/notification.model.js';

export const createOrder = async (req, res, next) => {
  try {
    const { items, time_slot, notes } = req.body;
    
    // In a real app, calculate totalAmount securely on backend by querying item prices
    // Here we assume items contain { item_id, quantity, price }
    let totalAmount = 0;
    items.forEach(i => {
      totalAmount += parseFloat(i.price) * parseInt(i.quantity);
    });

    const order = await placeOrder(req.user.id, items, totalAmount, time_slot, notes);
    
    // Notify admins via socket
    getIO().to('admins').emit('admin:orderUpdate', order);
    
    res.status(201).json({ message: 'Order placed', order });
  } catch (error) {
    next(error);
  }
};

export const getMyOrders = async (req, res, next) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;
    const data = await getOrdersByUser(req.user.id, limit, offset);
    res.status(200).json({ ...data, page, pages: Math.ceil(data.total / limit) });
  } catch (error) {
    next(error);
  }
};

export const getOrder = async (req, res, next) => {
  try {
    const order = await getOrderById(req.params.id);
    if (!order) return res.status(404).json({ error: 'Order not found' });
    
    // Security check: only owner or admin can view
    if (order.user_id !== req.user.id && req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Unauthorized' });
    }
    
    res.status(200).json({ order });
  } catch (error) {
    next(error);
  }
};
