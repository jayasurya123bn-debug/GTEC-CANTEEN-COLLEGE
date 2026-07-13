import { query } from '../config/database.js';

export const createNotification = async (userId, title, body, type, data = {}) => {
  const result = await query(`
    INSERT INTO notifications (user_id, title, body, type, data)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *
  `, [userId, title, body, type, JSON.stringify(data)]);
  return result.rows[0];
};

export const getUserNotifications = async (userId, limit = 20, offset = 0) => {
  const result = await query(`
    SELECT * FROM notifications
    WHERE user_id = $1
    ORDER BY created_at DESC
    LIMIT $2 OFFSET $3
  `, [userId, limit, offset]);
  return result.rows;
};

export const markAsRead = async (id, userId) => {
  await query(`
    UPDATE notifications SET is_read = true 
    WHERE id = $1 AND user_id = $2
  `, [id, userId]);
};

export const markAllAsRead = async (userId) => {
  await query(`
    UPDATE notifications SET is_read = true 
    WHERE user_id = $1
  `, [userId]);
};
