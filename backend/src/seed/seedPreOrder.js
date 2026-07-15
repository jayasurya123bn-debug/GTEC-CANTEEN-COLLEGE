/**
 * seedPreOrder.js
 * 
 * Updates pre_order_limit on all existing menu items.
 * Run once after applying pre_order_migration.sql:
 *   node backend/src/seed/seedPreOrder.js
 */

import { query, getClient } from '../config/database.js';
import logger from '../utils/logger.js';

const LIMIT_MAP = {
  // Breakfast items
  'Idli':              50,
  'Dosa':              40,
  'Masala Dosa':       35,
  'Pongal':            30,
  'Upma':              30,
  'Poha':              30,
  'Vada':              40,
  'Chapati':           50,
  'Parotta':           45,
  'Uthappam':          30,
  // Lunch items
  'Rice':              60,
  'Sambar Rice':       50,
  'Rasam Rice':        40,
  'Curd Rice':         45,
  'Lemon Rice':        35,
  'Vegetable Biryani': 25,
  'Biryani':           25,
  'Chole Bhature':     30,
  'Paneer Butter Masala': 20,
  'Dal Fry':           40,
  'Vegetable Curry':   40,
  'Rajma':             30,
  'Chana Masala':      30,
  'Mix Veg':           35,
  'Roti':              60,
  'Naan':              40,
  // Snacks items
  'Samosa':            60,
  'Pakoda':            50,
  'Bread Omelette':    40,
  'Sandwich':          40,
  'Veg Puff':          50,
  'Banana Bonda':      50,
  'Mirchi Bajji':      45,
  'Popcorn':           80,
  'Chips':             100,
  // Dinner items
  'Chapati Set':       35,
  'Parotta Set':       35,
  'Fried Rice':        30,
  'Noodles':           30,
  'Paneer Tikka':      20,
  'Mushroom Curry':    20,
  // Beverages (high limit)
  'Coffee':            100,
  'Tea':               100,
  'Milk':              100,
  'Lassi':             80,
  'Buttermilk':        100,
  'Juice':             80,
  'Cold Coffee':       80,
  'Milkshake':         60,
  'Lemonade':          80,
  'Badam Milk':        60,
};

const runSeedPreOrder = async () => {
  const client = await getClient();
  try {
    logger.info('Starting pre_order_limit seed...');

    // Fetch all items
    const items = await client.query(`SELECT id, name FROM menu_items WHERE is_active = true`);

    let updated = 0;
    for (const item of items.rows) {
      // Look for exact match first, then partial match
      let limit = LIMIT_MAP[item.name];
      if (limit === undefined) {
        // Try partial match (case-insensitive)
        const key = Object.keys(LIMIT_MAP).find((k) =>
          item.name.toLowerCase().includes(k.toLowerCase()) ||
          k.toLowerCase().includes(item.name.toLowerCase())
        );
        limit = key ? LIMIT_MAP[key] : 50; // Default to 50 if no match
      }

      await client.query(
        `UPDATE menu_items SET pre_order_limit = $1 WHERE id = $2`,
        [limit, item.id]
      );
      logger.info(`  ✓ ${item.name} → pre_order_limit = ${limit}`);
      updated++;
    }

    // Ensure today's meal slots exist
    const today = new Date().toISOString().split('T')[0];
    const slots = [
      { slot_name: 'breakfast', start_time: '07:00:00', end_time: '10:00:00' },
      { slot_name: 'lunch',     start_time: '12:00:00', end_time: '14:00:00' },
      { slot_name: 'snacks',    start_time: '16:00:00', end_time: '18:00:00' },
      { slot_name: 'dinner',    start_time: '19:00:00', end_time: '21:00:00' },
    ];

    for (const slot of slots) {
      await client.query(
        `INSERT INTO meal_slots (slot_name, start_time, end_time, date)
         VALUES ($1, $2, $3, $4)
         ON CONFLICT (slot_name, date) DO NOTHING`,
        [slot.slot_name, slot.start_time, slot.end_time, today]
      );
    }
    logger.info(`  ✓ Meal slots for ${today} ensured`);

    logger.info(`\nSeed complete! Updated ${updated} menu items with pre_order_limit values. 🌿`);
  } catch (err) {
    logger.error('Seed error:', err);
    process.exit(1);
  } finally {
    client.release();
    process.exit(0);
  }
};

runSeedPreOrder();
