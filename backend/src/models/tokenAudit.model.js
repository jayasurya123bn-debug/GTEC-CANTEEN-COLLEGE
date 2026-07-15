import { query } from '../config/database.js';

/**
 * Create a token audit record inside an existing client transaction.
 */
export const createAudit = async (client, orderId, tokenStart, tokenEnd, mealSlotId) => {
  const result = await client.query(
    `INSERT INTO token_audit (order_id, token_start, token_end, meal_slot_id)
     VALUES ($1, $2, $3, $4)
     RETURNING *`,
    [orderId, tokenStart, tokenEnd, mealSlotId]
  );
  return result.rows[0];
};

/**
 * Fetch the token audit record for a given order.
 */
export const getAuditByOrder = async (orderId) => {
  const result = await query(
    `SELECT * FROM token_audit WHERE order_id = $1`,
    [orderId]
  );
  return result.rows[0] || null;
};

/**
 * Fetch all token audit records for a given meal slot, ordered by token_start.
 * Optionally pass a date string (YYYY-MM-DD); defaults to today.
 */
export const getAuditBySlot = async (mealSlotId, date = null) => {
  const targetDate = date || new Date().toISOString().split('T')[0];
  const result = await query(
    `SELECT ta.*, o.status AS order_status, o.user_id,
            u.name AS student_name, o.department, o.year, o.section
     FROM token_audit ta
     JOIN orders o ON o.id = ta.order_id
     JOIN users u  ON u.id = o.user_id
     WHERE ta.meal_slot_id = $1
       AND DATE(ta.created_at) = $2
     ORDER BY ta.token_start`,
    [mealSlotId, targetDate]
  );
  return result.rows;
};
