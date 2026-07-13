import { query } from '../config/database.js';

export const getFavourites = async (userId) => {
  const result = await query(`
    SELECT f.item_id, f.created_at, mi.name, mi.price, mi.image_url, mi.availability, mi.dietary_tag, mc.name as category_name
    FROM favourites f
    JOIN menu_items mi ON f.item_id = mi.id
    JOIN menu_categories mc ON mi.category_id = mc.id
    WHERE f.user_id = $1 AND mi.is_active = true
    ORDER BY f.created_at DESC
  `, [userId]);
  return result.rows;
};

export const addFavourite = async (userId, itemId) => {
  await query(`
    INSERT INTO favourites (user_id, item_id)
    VALUES ($1, $2)
    ON CONFLICT DO NOTHING
  `, [userId, itemId]);
};

export const removeFavourite = async (userId, itemId) => {
  await query('DELETE FROM favourites WHERE user_id = $1 AND item_id = $2', [userId, itemId]);
};

export const checkFavourite = async (userId, itemId) => {
  const result = await query('SELECT 1 FROM favourites WHERE user_id = $1 AND item_id = $2', [userId, itemId]);
  return result.rows.length > 0;
};

export const getUsersWhoFavourited = async (itemId) => {
  const result = await query(`
    SELECT u.id, u.fcm_token 
    FROM favourites f
    JOIN users u ON f.user_id = u.id
    WHERE f.item_id = $1 AND u.fcm_token IS NOT NULL
  `, [itemId]);
  return result.rows;
};
