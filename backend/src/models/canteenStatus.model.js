import { query } from '../config/database.js';

export const getStatus = async () => {
  const result = await query('SELECT is_open, busyness, broadcast_message, updated_at FROM canteen_status ORDER BY id DESC LIMIT 1');
  if (result.rows.length === 0) {
    // Default if not initialized
    return { is_open: true, busyness: 'low', broadcast_message: null };
  }
  return result.rows[0];
};

export const updateStatus = async (isOpen, busyness, userId) => {
  const result = await query(
    `UPDATE canteen_status SET is_open = COALESCE($1, is_open), busyness = COALESCE($2, busyness), updated_by = $3, updated_at = CURRENT_TIMESTAMP
     RETURNING is_open, busyness, broadcast_message, updated_at`,
    [isOpen, busyness, userId]
  );
  return result.rows[0];
};

export const updateBroadcast = async (message, userId) => {
  const result = await query(
    `UPDATE canteen_status SET broadcast_message = $1, updated_by = $2, updated_at = CURRENT_TIMESTAMP
     RETURNING is_open, busyness, broadcast_message, updated_at`,
    [message, userId]
  );
  return result.rows[0];
};
