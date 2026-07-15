import { query } from '../config/database.js';

// ─── reads ─────────────────────────────────────────────────────────────────

/**
 * Get the booking record for a specific menu item in a specific slot for today.
 * Returns null if no booking exists yet (item hasn't been pre-ordered yet).
 */
export const getBooking = async (menuItemId, mealSlotId, date = null) => {
  const targetDate = date || new Date().toISOString().split('T')[0];
  const result = await query(
    `SELECT * FROM pre_order_bookings
     WHERE menu_item_id = $1 AND meal_slot_id = $2 AND date = $3`,
    [menuItemId, mealSlotId, targetDate]
  );
  return result.rows[0] || null;
};

/**
 * Get booking record for a menu item in a slot — INSIDE a client transaction.
 * Uses FOR UPDATE to lock the row and prevent concurrent over-booking.
 */
export const getBookingForUpdate = async (client, menuItemId, mealSlotId, date = null) => {
  const targetDate = date || new Date().toISOString().split('T')[0];
  const result = await client.query(
    `SELECT pob.*, mi.pre_order_limit
     FROM pre_order_bookings pob
     JOIN menu_items mi ON mi.id = pob.menu_item_id
     WHERE pob.menu_item_id = $1 AND pob.meal_slot_id = $2 AND pob.date = $3
     FOR UPDATE`,
    [menuItemId, mealSlotId, targetDate]
  );
  return result.rows[0] || null;
};

/**
 * Get the current capacity info for a menu item in a slot.
 * Returns: { booked_quantity, pre_order_limit, remaining, status }
 */
export const getItemCapacity = async (menuItemId, mealSlotId, date = null) => {
  const targetDate = date || new Date().toISOString().split('T')[0];
  const result = await query(
    `SELECT
       mi.id             AS menu_item_id,
       mi.pre_order_limit,
       COALESCE(pob.booked_quantity, 0) AS booked_quantity,
       GREATEST(0, mi.pre_order_limit - COALESCE(pob.booked_quantity, 0)) AS remaining
     FROM menu_items mi
     LEFT JOIN pre_order_bookings pob
       ON pob.menu_item_id = mi.id
       AND pob.meal_slot_id = $2
       AND pob.date = $3
     WHERE mi.id = $1`,
    [menuItemId, mealSlotId, targetDate]
  );
  if (!result.rows[0]) return null;
  const row = result.rows[0];
  const pct = row.pre_order_limit > 0
    ? (row.booked_quantity / row.pre_order_limit) * 100
    : 100;
  const status = pct >= 100 ? 'sold_out' : pct >= 80 ? 'limited' : 'available';
  return { ...row, status };
};

/**
 * Get all bookings for a slot on a given date, joined with menu item info.
 */
export const getBookingsForSlot = async (mealSlotId, date = null) => {
  const targetDate = date || new Date().toISOString().split('T')[0];
  const result = await query(
    `SELECT
       pob.*,
       mi.name              AS item_name,
       mi.price             AS item_price,
       mi.pre_order_limit,
       GREATEST(0, mi.pre_order_limit - pob.booked_quantity) AS remaining,
       CASE
         WHEN mi.pre_order_limit = 0 THEN 'sold_out'
         WHEN pob.booked_quantity >= mi.pre_order_limit THEN 'sold_out'
         WHEN pob.booked_quantity >= mi.pre_order_limit * 0.8 THEN 'limited'
         ELSE 'available'
       END AS status
     FROM pre_order_bookings pob
     JOIN menu_items mi ON mi.id = pob.menu_item_id
     WHERE pob.meal_slot_id = $1 AND pob.date = $2
     ORDER BY mi.name`,
    [mealSlotId, targetDate]
  );
  return result.rows;
};

// ─── writes ────────────────────────────────────────────────────────────────

/**
 * Atomically increment the booked quantity for a menu item in a slot.
 * Uses INSERT … ON CONFLICT so it works even if no prior booking row exists.
 * Must be called INSIDE an existing client transaction.
 */
export const incrementBooking = async (client, menuItemId, mealSlotId, qty, date = null) => {
  const targetDate = date || new Date().toISOString().split('T')[0];
  const result = await client.query(
    `INSERT INTO pre_order_bookings (menu_item_id, meal_slot_id, booked_quantity, date)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (menu_item_id, meal_slot_id, date) DO UPDATE
       SET booked_quantity = pre_order_bookings.booked_quantity + EXCLUDED.booked_quantity,
           updated_at      = NOW()
     RETURNING *`,
    [menuItemId, mealSlotId, qty, targetDate]
  );
  return result.rows[0];
};

/**
 * Decrement the booked quantity (on order cancellation).
 * Will not go below 0.
 * NOT required to be inside a transaction but safe if it is.
 */
export const decrementBooking = async (menuItemId, mealSlotId, qty, date = null) => {
  const targetDate = date || new Date().toISOString().split('T')[0];
  const result = await query(
    `UPDATE pre_order_bookings
     SET booked_quantity = GREATEST(0, booked_quantity - $1),
         updated_at      = NOW()
     WHERE menu_item_id = $2 AND meal_slot_id = $3 AND date = $4
     RETURNING *`,
    [qty, menuItemId, mealSlotId, targetDate]
  );
  return result.rows[0] || null;
};

/**
 * Delete all booking rows for a slot (used in slot reset).
 */
export const resetBookingsForSlot = async (mealSlotId, date = null) => {
  const targetDate = date || new Date().toISOString().split('T')[0];
  await query(
    `DELETE FROM pre_order_bookings WHERE meal_slot_id = $1 AND date = $2`,
    [mealSlotId, targetDate]
  );
};
