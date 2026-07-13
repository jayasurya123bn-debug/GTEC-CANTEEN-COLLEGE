import { query } from '../config/database.js';

export const getMenuItems = async ({ category, availability, dietary_tag }) => {
  let sql = `
    SELECT mi.*, mc.name as category_name
    FROM menu_items mi
    JOIN menu_categories mc ON mi.category_id = mc.id
    WHERE mi.is_active = true
  `;
  const params = [];
  let paramCount = 1;

  if (category) {
    sql += ` AND mi.category_id = $${paramCount}`;
    params.push(category);
    paramCount++;
  }
  if (availability) {
    sql += ` AND mi.availability = $${paramCount}`;
    params.push(availability);
    paramCount++;
  }
  if (dietary_tag) {
    sql += ` AND mi.dietary_tag = $${paramCount}`;
    params.push(dietary_tag);
    paramCount++;
  }

  sql += ` ORDER BY mc.display_order, mi.name`;

  const result = await query(sql, params);
  return result.rows;
};

export const getMenuItemById = async (id) => {
  const result = await query(`
    SELECT mi.*, mc.name as category_name
    FROM menu_items mi
    JOIN menu_categories mc ON mi.category_id = mc.id
    WHERE mi.id = $1 AND mi.is_active = true
  `, [id]);
  return result.rows[0];
};

export const createMenuItem = async (item) => {
  // CRITICAL: is_veg is hardcoded to true
  const { category_id, name, description, price, image_url, dietary_tag, availability, limited_quantity } = item;
  const result = await query(`
    INSERT INTO menu_items (category_id, name, description, price, image_url, is_veg, dietary_tag, availability, limited_quantity)
    VALUES ($1, $2, $3, $4, $5, true, $6, $7, $8)
    RETURNING *
  `, [category_id, name, description, price, image_url, dietary_tag, availability, limited_quantity]);
  return result.rows[0];
};

export const updateMenuItem = async (id, item) => {
  const { category_id, name, description, price, image_url, dietary_tag, availability, limited_quantity } = item;
  const result = await query(`
    UPDATE menu_items 
    SET category_id = $1, name = $2, description = $3, price = $4, image_url = $5, dietary_tag = $6, availability = $7, limited_quantity = $8, updated_at = CURRENT_TIMESTAMP
    WHERE id = $9
    RETURNING *
  `, [category_id, name, description, price, image_url, dietary_tag, availability, limited_quantity, id]);
  return result.rows[0];
};

export const updateAvailability = async (id, availability, limited_quantity) => {
  const result = await query(`
    UPDATE menu_items 
    SET availability = $1, limited_quantity = $2, updated_at = CURRENT_TIMESTAMP
    WHERE id = $3
    RETURNING *
  `, [availability, limited_quantity, id]);
  return result.rows[0];
};

export const deleteMenuItem = async (id) => {
  const result = await query(`
    UPDATE menu_items SET is_active = false, updated_at = CURRENT_TIMESTAMP WHERE id = $1 RETURNING id
  `, [id]);
  return result.rows[0];
};

export const updateItemRating = async (id, newRating) => {
  await query(`
    UPDATE menu_items 
    SET rating_count = rating_count + 1, 
        avg_rating = ((avg_rating * rating_count) + $1) / (rating_count + 1)
    WHERE id = $2
  `, [newRating, id]);
};
