import { query, getClient } from '../config/database.js';

// ─── helpers ───────────────────────────────────────────────────────────────

/**
 * Determine which meal slot name is active right now based on wall-clock time.
 * Returns null if the current time is outside all defined meal windows.
 */
export const detectCurrentSlotName = () => {
  const now = new Date();
  // Use local hours/minutes in the server's timezone
  const h = now.getHours();
  const m = now.getMinutes();
  const totalMin = h * 60 + m;

  if (totalMin >= 7 * 60 && totalMin < 10 * 60)  return 'breakfast';
  if (totalMin >= 12 * 60 && totalMin < 14 * 60) return 'lunch';
  if (totalMin >= 16 * 60 && totalMin < 18 * 60) return 'snacks';
  if (totalMin >= 19 * 60 && totalMin < 21 * 60) return 'dinner';
  return null;
};

// ─── reads ─────────────────────────────────────────────────────────────────

/**
 * Fetch a meal slot for a specific slot name and date (default: today).
 */
export const getSlotByNameAndDate = async (slotName, date = null) => {
  const targetDate = date || new Date().toISOString().split('T')[0];
  const result = await query(
    `SELECT * FROM meal_slots WHERE slot_name = $1 AND date = $2`,
    [slotName, targetDate]
  );
  return result.rows[0] || null;
};

/**
 * Return the slot that is currently active based on time.
 * Creates it if it doesn't exist for today yet.
 */
export const getCurrentSlot = async () => {
  const slotName = detectCurrentSlotName();
  if (!slotName) return null;

  const today = new Date().toISOString().split('T')[0];
  let slot = await getSlotByNameAndDate(slotName, today);
  if (!slot) {
    slot = await createSlotForToday(slotName);
  }
  return slot;
};

/**
 * Get all slots for today.
 */
export const getAllSlotsForToday = async () => {
  const today = new Date().toISOString().split('T')[0];
  const result = await query(
    `SELECT * FROM meal_slots WHERE date = $1 ORDER BY start_time`,
    [today]
  );
  return result.rows;
};

/**
 * Get a slot by its UUID.
 */
export const getSlotById = async (id) => {
  const result = await query(`SELECT * FROM meal_slots WHERE id = $1`, [id]);
  return result.rows[0] || null;
};

// ─── writes ────────────────────────────────────────────────────────────────

const SLOT_TIMES = {
  breakfast: { start: '07:00:00', end: '10:00:00' },
  lunch:     { start: '12:00:00', end: '14:00:00' },
  snacks:    { start: '16:00:00', end: '18:00:00' },
  dinner:    { start: '19:00:00', end: '21:00:00' },
};

/**
 * Ensure today's row for a given slot exists. Safe to call many times.
 */
export const createSlotForToday = async (slotName) => {
  const today = new Date().toISOString().split('T')[0];
  const times = SLOT_TIMES[slotName];
  if (!times) throw new Error(`Unknown slot name: ${slotName}`);

  const result = await query(
    `INSERT INTO meal_slots (slot_name, start_time, end_time, date)
     VALUES ($1, $2, $3, $4)
     ON CONFLICT (slot_name, date) DO UPDATE
       SET is_active = TRUE
     RETURNING *`,
    [slotName, times.start, times.end, today]
  );
  return result.rows[0];
};

/**
 * Atomically increment the token counter by `delta` and return the NEW value.
 * Must be called INSIDE an existing client transaction.
 */
export const updateTokenCounter = async (client, slotId, delta) => {
  const result = await client.query(
    `UPDATE meal_slots
     SET current_token_number = current_token_number + $1
     WHERE id = $2
     RETURNING current_token_number`,
    [delta, slotId]
  );
  return result.rows[0].current_token_number;
};

/**
 * Reset a slot's token counter to 0 and clear its now_serving number.
 */
export const resetSlot = async (slotId) => {
  const result = await query(
    `UPDATE meal_slots
     SET current_token_number = 0,
         now_serving = 0
     WHERE id = $1
     RETURNING *`,
    [slotId]
  );
  return result.rows[0];
};

/**
 * Update the "now serving" token number for a slot.
 */
export const updateNowServing = async (slotId, tokenNumber) => {
  const result = await query(
    `UPDATE meal_slots
     SET now_serving = $1
     WHERE id = $2
     RETURNING *`,
    [tokenNumber, slotId]
  );
  return result.rows[0];
};
