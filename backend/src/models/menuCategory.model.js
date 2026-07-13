import { query } from '../config/database.js';

export const getAllCategories = async () => {
  const result = await query('SELECT * FROM menu_categories WHERE is_active = true ORDER BY display_order');
  return result.rows;
};

export const getCategoryWithCounts = async () => {
  const result = await query(`
    SELECT mc.*, COUNT(mi.id) as item_count 
    FROM menu_categories mc
    LEFT JOIN menu_items mi ON mc.id = mi.category_id AND mi.is_active = true
    WHERE mc.is_active = true
    GROUP BY mc.id
    ORDER BY mc.display_order
  `);
  return result.rows;
};
