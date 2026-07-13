import { query } from '../config/database.js';

export const getReviewsByItemId = async (itemId, limit = 10, offset = 0) => {
  const result = await query(`
    SELECT r.*, u.name as user_name, u.avatar_url 
    FROM reviews r
    JOIN users u ON r.user_id = u.id
    WHERE r.item_id = $1 AND r.is_approved = true
    ORDER BY r.created_at DESC
    LIMIT $2 OFFSET $3
  `, [itemId, limit, offset]);
  
  const countResult = await query('SELECT COUNT(*) FROM reviews WHERE item_id = $1 AND is_approved = true', [itemId]);
  
  return {
    reviews: result.rows,
    total: parseInt(countResult.rows[0].count)
  };
};

export const createReview = async (itemId, userId, rating, comment) => {
  const result = await query(`
    INSERT INTO reviews (item_id, user_id, rating, comment)
    VALUES ($1, $2, $3, $4)
    RETURNING *
  `, [itemId, userId, rating, comment]);
  return result.rows[0];
};

export const getAllReviews = async ({ is_approved, item_id }) => {
  let sql = `
    SELECT r.*, u.name as user_name, mi.name as item_name
    FROM reviews r
    JOIN users u ON r.user_id = u.id
    JOIN menu_items mi ON r.item_id = mi.id
    WHERE 1=1
  `;
  const params = [];
  let paramCount = 1;

  if (is_approved !== undefined) {
    sql += ` AND r.is_approved = $${paramCount}`;
    params.push(is_approved);
    paramCount++;
  }
  
  if (item_id) {
    sql += ` AND r.item_id = $${paramCount}`;
    params.push(item_id);
    paramCount++;
  }

  sql += ` ORDER BY r.created_at DESC`;

  const result = await query(sql, params);
  return result.rows;
};

export const updateReviewStatus = async (id, is_approved) => {
  const result = await query(`
    UPDATE reviews SET is_approved = $1 WHERE id = $2 RETURNING *
  `, [is_approved, id]);
  return result.rows[0];
};

export const deleteReview = async (id) => {
  await query('DELETE FROM reviews WHERE id = $1', [id]);
};

export const getReviewById = async (id) => {
  const result = await query(`
    SELECT r.*, u.name as user_name, mi.name as item_name
    FROM reviews r
    JOIN users u ON r.user_id = u.id
    JOIN menu_items mi ON r.item_id = mi.id
    WHERE r.id = $1
  `, [id]);
  return result.rows[0];
};
