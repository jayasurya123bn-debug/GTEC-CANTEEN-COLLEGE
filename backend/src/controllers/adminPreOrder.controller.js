import { query, getClient } from '../config/database.js';
import {
  getCurrentSlot,
  getSlotByNameAndDate,
  createSlotForToday,
  resetSlot,
  updateNowServing,
  getAllSlotsForToday,
} from '../models/mealSlot.model.js';
import {
  getBookingsForSlot,
  resetBookingsForSlot,
  getItemCapacity,
} from '../models/preOrderBooking.model.js';
import { getAuditBySlot } from '../models/tokenAudit.model.js';
import { getIO } from '../services/socket.service.js';
import logger from '../utils/logger.js';

// ─── helper ────────────────────────────────────────────────────────────────
const deriveStatus = (booked, limit) => {
  if (limit === 0 || booked >= limit) return 'sold_out';
  if (booked / limit >= 0.8)         return 'limited';
  return 'available';
};

// ─── GET /api/v1/admin/pre-order/dashboard ─────────────────────────────────
export const getDashboard = async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const slot  = await getCurrentSlot();

    let slotData = null;
    let itemBreakdown = [];
    let departmentSummary = {};
    let orders = [];

    if (slot) {
      // Per-item capacity breakdown
      const bookingsRaw = await getBookingsForSlot(slot.id, today);
      itemBreakdown = bookingsRaw.map((b) => ({
        menu_item_id:  b.menu_item_id,
        item_name:     b.item_name,
        pre_order_limit: b.pre_order_limit,
        booked_qty:    b.booked_quantity,
        remaining:     b.remaining,
        status:        b.status,
      }));

      // Also include items with 0 bookings
      const allItemsRes = await query(
        `SELECT mi.id, mi.name, mi.pre_order_limit,
                COALESCE(pob.booked_quantity, 0) AS booked_quantity,
                GREATEST(0, mi.pre_order_limit - COALESCE(pob.booked_quantity, 0)) AS remaining
         FROM menu_items mi
         LEFT JOIN pre_order_bookings pob
           ON pob.menu_item_id = mi.id AND pob.meal_slot_id = $1 AND pob.date = $2
         WHERE mi.is_active = true
         ORDER BY mi.name`,
        [slot.id, today]
      );
      itemBreakdown = allItemsRes.rows.map((r) => ({
        menu_item_id:    r.id,
        item_name:       r.name,
        pre_order_limit: r.pre_order_limit,
        booked_qty:      parseInt(r.booked_quantity),
        remaining:       parseInt(r.remaining),
        status:          deriveStatus(r.booked_quantity, r.pre_order_limit),
      }));

      // Orders for current slot
      const ordersRes = await query(
        `SELECT o.*, u.name AS student_name, ta.token_start, ta.token_end
         FROM orders o
         JOIN users u ON u.id = o.user_id
         JOIN token_audit ta ON ta.order_id = o.id
         WHERE o.meal_slot_id = $1 AND o.order_type = 'pre_order'
         ORDER BY o.token_number`,
        [slot.id]
      );
      orders = ordersRes.rows.map((r) => ({
        id:           r.id,
        token_number: r.token_number,
        token_start:  r.token_start,
        token_end:    r.token_end,
        student_name: r.student_name,
        department:   r.department,
        year:         r.year,
        section:      r.section,
        items:        typeof r.items === 'string' ? JSON.parse(r.items) : r.items,
        total_items:  r.total_items,
        total_amount: parseFloat(r.total_amount),
        pickup_time:  r.pickup_time,
        status:       r.status,
        created_at:   r.created_at,
      }));

      // Department-wise summary
      ordersRes.rows.forEach((o) => {
        if (o.department) {
          departmentSummary[o.department] = (departmentSummary[o.department] || 0) + 1;
        }
      });

      slotData = {
        id:                   slot.id,
        slot_name:            slot.slot_name,
        start_time:           slot.start_time,
        end_time:             slot.end_time,
        current_token_number: slot.current_token_number,
        now_serving:          slot.now_serving,
        date:                 slot.date,
      };
    }

    const totalOrders   = orders.length;
    const totalPortions = orders.reduce((s, o) => s + (o.total_items || 0), 0);
    const soldOutCount  = itemBreakdown.filter((i) => i.status === 'sold_out').length;
    const avgItemsPerOrder = totalOrders > 0
      ? parseFloat((totalPortions / totalOrders).toFixed(2))
      : 0;

    return res.status(200).json({
      current_slot:        slotData,
      total_orders:        totalOrders,
      total_portions:      totalPortions,
      items_sold_out:      soldOutCount,
      avg_items_per_order: avgItemsPerOrder,
      item_breakdown:      itemBreakdown,
      orders,
      department_summary:  departmentSummary,
    });
  } catch (err) {
    logger.error('getDashboard error:', err);
    return res.status(500).json({ error: 'Failed to fetch pre-order dashboard' });
  }
};

// ─── GET /api/v1/admin/pre-order/orders?meal_slot=lunch&status=pending&department=CSE
export const getPreOrders = async (req, res) => {
  try {
    const { meal_slot, status, department, year, section, date: dateParam } = req.query;
    const today = dateParam || new Date().toISOString().split('T')[0];

    let slotId = null;
    if (meal_slot) {
      const slot = await getSlotByNameAndDate(meal_slot, today);
      if (slot) slotId = slot.id;
    }

    const params = [];
    let paramCount = 1;
    let sql = `
      SELECT o.*, u.name AS student_name, ta.token_start, ta.token_end,
             ms.slot_name, ms.start_time AS slot_start_time, ms.end_time AS slot_end_time
      FROM orders o
      JOIN users u      ON u.id  = o.user_id
      JOIN token_audit ta ON ta.order_id = o.id
      JOIN meal_slots ms   ON ms.id = o.meal_slot_id
      WHERE o.order_type = 'pre_order'
    `;

    if (slotId) {
      sql += ` AND o.meal_slot_id = $${paramCount++}`;
      params.push(slotId);
    } else {
      // Scope to today
      sql += ` AND DATE(o.created_at) = $${paramCount++}`;
      params.push(today);
    }

    if (status) {
      sql += ` AND o.status = $${paramCount++}`;
      params.push(status);
    }
    if (department) {
      sql += ` AND o.department = $${paramCount++}`;
      params.push(department);
    }
    if (year) {
      sql += ` AND o.year = $${paramCount++}`;
      params.push(year);
    }
    if (section) {
      sql += ` AND o.section = $${paramCount++}`;
      params.push(section);
    }

    sql += ` ORDER BY o.token_number NULLS LAST, o.created_at`;

    const result = await query(sql, params);
    const orders = result.rows.map((r) => ({
      id:           r.id,
      token_number: r.token_number,
      token_start:  r.token_start,
      token_end:    r.token_end,
      student_name: r.student_name,
      department:   r.department,
      year:         r.year,
      section:      r.section,
      meal_slot:    r.slot_name,
      slot_start:   r.slot_start_time,
      slot_end:     r.slot_end_time,
      items:        typeof r.items === 'string' ? JSON.parse(r.items) : r.items,
      total_items:  r.total_items,
      total_amount: parseFloat(r.total_amount),
      pickup_time:  r.pickup_time,
      status:       r.status,
      created_at:   r.created_at,
    }));

    return res.status(200).json({ orders, total: orders.length });
  } catch (err) {
    logger.error('getPreOrders error:', err);
    return res.status(500).json({ error: 'Failed to fetch pre-orders' });
  }
};

// ─── PATCH /api/v1/admin/pre-order/:orderId/status ─────────────────────────
export const updatePreOrderStatus = async (req, res) => {
  try {
    const { orderId } = req.params;
    const { status }  = req.body;

    // Valid transitions
    const VALID_TRANSITIONS = {
      pending:   ['confirmed', 'cancelled'],
      confirmed: ['preparing', 'cancelled'],
      preparing: ['ready',     'cancelled'],
      ready:     ['completed', 'cancelled'],
      completed: [],
      cancelled: [],
    };

    const orderRes = await query(`SELECT * FROM orders WHERE id = $1`, [orderId]);
    const order = orderRes.rows[0];
    if (!order) return res.status(404).json({ error: 'Order not found' });

    const allowed = VALID_TRANSITIONS[order.status] || [];
    if (!allowed.includes(status)) {
      return res.status(400).json({
        error: 'Invalid status transition',
        message: `Cannot move from '${order.status}' to '${status}'. Allowed: [${allowed.join(', ')}]`,
      });
    }

    const updated = await query(
      `UPDATE orders SET status = $1, updated_at = NOW() WHERE id = $2 RETURNING *`,
      [status, orderId]
    );

    try {
      const io = getIO();
      io.emit('order:statusUpdate', {
        orderId,
        status,
        tokenNumber: order.token_number,
      });
      // Also notify the specific student
      io.to(`user:${order.user_id}`).emit('order:statusUpdate', {
        orderId,
        status,
        tokenNumber: order.token_number,
      });
    } catch (socketErr) {
      logger.warn('Socket emit error (non-fatal):', socketErr.message);
    }

    return res.status(200).json({ order: updated.rows[0] });
  } catch (err) {
    logger.error('updatePreOrderStatus error:', err);
    return res.status(500).json({ error: 'Failed to update order status' });
  }
};

// ─── PATCH /api/v1/admin/menu/:itemId/pre-order-limit ──────────────────────
export const updatePreOrderLimit = async (req, res) => {
  try {
    const { itemId } = req.params;
    const { pre_order_limit } = req.body;
    const today = new Date().toISOString().split('T')[0];

    const itemRes = await query(
      `UPDATE menu_items SET pre_order_limit = $1, updated_at = NOW()
       WHERE id = $2 RETURNING *`,
      [pre_order_limit, itemId]
    );
    if (!itemRes.rows[0]) {
      return res.status(404).json({ error: 'Menu item not found' });
    }

    const item = itemRes.rows[0];

    // Determine current booked qty for all active slots today
    const bookedRes = await query(
      `SELECT pob.booked_quantity, pob.meal_slot_id, ms.slot_name
       FROM pre_order_bookings pob
       JOIN meal_slots ms ON ms.id = pob.meal_slot_id
       WHERE pob.menu_item_id = $1 AND pob.date = $2`,
      [itemId, today]
    );

    // Emit to all clients per slot
    try {
      const io = getIO();
      for (const booking of bookedRes.rows) {
        const status = deriveStatus(booking.booked_quantity, pre_order_limit);
        const remaining = Math.max(0, pre_order_limit - booking.booked_quantity);
        io.emit('pre_order:capacityUpdate', {
          itemId,
          remaining,
          status,
          mealSlot: booking.slot_name,
        });
        if (status === 'sold_out') {
          io.emit('pre_order:soldOut', {
            itemId,
            itemName: item.name,
            mealSlot: booking.slot_name,
          });
        }
        io.emit('menu:itemUpdate', { item: { ...item, price: parseFloat(item.price) } });
      }
    } catch (socketErr) {
      logger.warn('Socket emit error (non-fatal):', socketErr.message);
    }

    return res.status(200).json({
      message: 'Pre-order limit updated',
      item: { ...item, price: parseFloat(item.price) },
      bookings: bookedRes.rows,
    });
  } catch (err) {
    logger.error('updatePreOrderLimit error:', err);
    return res.status(500).json({ error: 'Failed to update pre-order limit' });
  }
};

// ─── POST /api/v1/admin/meal-slot/reset ────────────────────────────────────
export const resetMealSlot = async (req, res) => {
  try {
    const { slot_name } = req.body;
    const today = new Date().toISOString().split('T')[0];

    const slot = await getSlotByNameAndDate(slot_name, today);
    if (!slot) {
      return res.status(404).json({ error: `No slot found for '${slot_name}' today` });
    }

    await resetBookingsForSlot(slot.id, today);
    const resetResult = await resetSlot(slot.id);

    // Cancel all pending orders for this slot today
    await query(
      `UPDATE orders SET status = 'cancelled', updated_at = NOW()
       WHERE meal_slot_id = $1 AND status IN ('pending','confirmed') AND DATE(created_at) = $2`,
      [slot.id, today]
    );

    return res.status(200).json({
      message: `Slot '${slot_name}' has been reset. Token counter is back to 0. All pending/confirmed orders cancelled.`,
      slot: resetResult,
    });
  } catch (err) {
    logger.error('resetMealSlot error:', err);
    return res.status(500).json({ error: 'Failed to reset meal slot' });
  }
};

// ─── GET /api/v1/admin/token-queue ─────────────────────────────────────────
export const getTokenQueue = async (req, res) => {
  try {
    const { meal_slot, date: dateParam } = req.query;
    const today = dateParam || new Date().toISOString().split('T')[0];

    let slot;
    if (meal_slot) {
      slot = await getSlotByNameAndDate(meal_slot, today);
    } else {
      slot = await getCurrentSlot();
    }

    if (!slot) {
      return res.status(200).json({
        slot: null,
        queue: [],
        now_serving: 0,
      });
    }

    const ordersRes = await query(
      `SELECT o.*, u.name AS student_name, ta.token_start, ta.token_end
       FROM orders o
       JOIN users u        ON u.id = o.user_id
       JOIN token_audit ta ON ta.order_id = o.id
       WHERE o.meal_slot_id = $1 AND o.order_type = 'pre_order'
       ORDER BY ta.token_start`,
      [slot.id]
    );

    const queue = ordersRes.rows.map((r) => ({
      id:           r.id,
      token_number: r.token_number,
      token_start:  r.token_start,
      token_end:    r.token_end,
      student_name: r.student_name,
      department:   r.department,
      year:         r.year,
      section:      r.section,
      items:        typeof r.items === 'string' ? JSON.parse(r.items) : r.items,
      total_items:  r.total_items,
      total_amount: parseFloat(r.total_amount),
      pickup_time:  r.pickup_time,
      status:       r.status,
      created_at:   r.created_at,
      is_now_serving: r.token_start <= slot.now_serving && slot.now_serving <= r.token_end,
    }));

    return res.status(200).json({
      slot: {
        id:                   slot.id,
        slot_name:            slot.slot_name,
        current_token_number: slot.current_token_number,
        now_serving:          slot.now_serving,
        date:                 slot.date,
      },
      queue,
      now_serving: slot.now_serving,
      total_in_queue: queue.length,
    });
  } catch (err) {
    logger.error('getTokenQueue error:', err);
    return res.status(500).json({ error: 'Failed to fetch token queue' });
  }
};

// ─── PATCH /api/v1/admin/token-queue/now-serving ───────────────────────────
export const setNowServing = async (req, res) => {
  try {
    const { token_number, slot_name } = req.body;
    const today = new Date().toISOString().split('T')[0];

    let slot;
    if (slot_name) {
      slot = await getSlotByNameAndDate(slot_name, today);
    } else {
      slot = await getCurrentSlot();
    }

    if (!slot) {
      return res.status(404).json({ error: 'No active slot found' });
    }

    const updated = await updateNowServing(slot.id, token_number);

    try {
      const io = getIO();
      io.emit('canteen:nowServing', {
        tokenNumber: token_number,
        mealSlot:    slot.slot_name,
        timestamp:   new Date().toISOString(),
      });
    } catch (socketErr) {
      logger.warn('Socket emit error (non-fatal):', socketErr.message);
    }

    return res.status(200).json({
      message: `Now serving token #${token_number}`,
      slot:    updated,
    });
  } catch (err) {
    logger.error('setNowServing error:', err);
    return res.status(500).json({ error: 'Failed to update now serving' });
  }
};
