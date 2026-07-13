import { getUserNotifications, markAsRead as updateMarkRead, markAllAsRead as updateMarkAll } from '../models/notification.model.js';

export const getNotifications = async (req, res, next) => {
  try {
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    const notifications = await getUserNotifications(req.user.id, limit, offset);
    res.status(200).json({ notifications });
  } catch (error) {
    next(error);
  }
};

export const markAsRead = async (req, res, next) => {
  try {
    await updateMarkRead(req.params.id, req.user.id);
    res.status(200).json({ message: 'Marked as read' });
  } catch (error) {
    next(error);
  }
};

export const markAllAsRead = async (req, res, next) => {
  try {
    await updateMarkAll(req.user.id);
    res.status(200).json({ message: 'All marked as read' });
  } catch (error) {
    next(error);
  }
};
