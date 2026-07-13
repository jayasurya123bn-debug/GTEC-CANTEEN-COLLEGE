import { query } from '../config/database.js';

export const getScheduledMenu = async (date) => {
  const result = await query(`
    SELECT sm.id as schedule_id, sm.meal_type, mi.*, mc.name as category_name
    FROM scheduled_menus sm
    JOIN menu_items mi ON sm.item_id = mi.id
    JOIN menu_categories mc ON mi.category_id = mc.id
    WHERE sm.scheduled_date = $1 AND mi.is_active = true
    ORDER BY mc.display_order
  `, [date]);
  return result.rows;
};

export const scheduleItem = async (itemId, date, mealType, adminId) => {
  const result = await query(`
    INSERT INTO scheduled_menus (item_id, scheduled_date, meal_type, created_by)
    VALUES ($1, $2, $3, $4)
    RETURNING *
  `, [itemId, date, mealType, adminId]);
  return result.rows[0];
};

export const removeScheduledItem = async (scheduleId) => {
  await query('DELETE FROM scheduled_menus WHERE id = $1', [scheduleId]);
};
