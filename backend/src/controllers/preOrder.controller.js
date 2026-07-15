import { getClient, query } from '../config/database.js';
import {
  getCurrentSlot,
  getSlotByNameAndDate,
  createSlotForToday,
  updateTokenCounter,
  detectCurrentSlotName,
} from '../models/mealSlot.model.js';
import {
  getBookingsForSlot,
  getBookingForUpdate,
  incrementBooking,
  decrementBooking,
  getItemCapacity,
} from '../models/preOrderBooking.model.js';
import { createAudit, getAuditByOrder } from '../models/tokenAudit.model.js';
import { getIO } from '../services/socket.service.js';
import logger from '../utils/logger.js';

// ─── helper: derive pre-order status ───────────────────────────────────────
const deriveStatus = (booked, limit) => {
  if (limit === 0) return 'sold_out';
  const pct = (booked / limit) * 100;
  if (pct >= 100) return 'sold_out';
  if (pct >= 80)  return 'limited';
  return 'available';
};

// ─── GET /api/v1/pre-order/available?meal_slot=lunch ───────────────────────
export const getAvailableItems = async (req, res) => {
  try {
    const { meal_slot } = req.query;
    const today = new Date().toISOString().split('T')[0];

    // Resolve slot
    let slot;
    if (meal_slot) {
      slot = await getSlotByNameAndDate(meal_slot, today);
      if (!slot) slot = await createSlotForToday(meal_slot);
    } else {
      slot = await getCurrentSlot();
    }

    if (!slot) {
      return res.status(200).json({
        slot: null,
        message: 'No active meal slot right now. Pre-ordering is not available.',
        items: [],
      });
    }

    // Fetch all active menu items with their booking status for this slot
    const result = await query(
      `SELECT
         mi.id,
         mi.category_id,
         mi.name,
         mi.description,
         mi.price,
         mi.image_url,
         mi.is_veg,
         mi.dietary_tag,
         mi.availability,
         mi.limited_quantity,
         mi.avg_rating,
         mi.rating_count,
         mi.pre_order_limit,
         mc.name AS category_name,
         COALESCE(pob.booked_quantity, 0) AS booked_quantity,
         GREATEST(0, mi.pre_order_limit - COALESCE(pob.booked_quantity, 0)) AS remaining_pre_order_capacity
       FROM menu_items mi
       JOIN menu_categories mc ON mc.id = mi.category_id
       LEFT JOIN pre_order_bookings pob
         ON pob.menu_item_id = mi.id
         AND pob.meal_slot_id = $1
         AND pob.date = $2
       WHERE mi.is_active = true
       ORDER BY mc.display_order, mi.name`,
      [slot.id, today]
    );

    const items = result.rows.map((item) => ({
      ...item,
      price: parseFloat(item.price),
      pre_order_status: deriveStatus(item.booked_quantity, item.pre_order_limit),
      is_pre_orderable:
        item.pre_order_limit > 0 &&
        item.booked_quantity < item.pre_order_limit,
    }));

    return res.status(200).json({
      slot: {
        id:                    slot.id,
        slot_name:             slot.slot_name,
        start_time:            slot.start_time,
        end_time:              slot.end_time,
        current_token_number:  slot.current_token_number,
        now_serving:           slot.now_serving,
        date:                  slot.date,
      },
      items,
    });
  } catch (err) {
    logger.error('getAvailableItems error:', err);
    return res.status(500).json({ error: 'Failed to fetch available pre-order items' });
  }
};

// ─── GET /api/v1/pre-order/slot-status ─────────────────────────────────────
export const getSlotStatus = async (req, res) => {
  try {
    const slot = await getCurrentSlot();

    if (!slot) {
      return res.status(200).json({
        active: false,
        slot:   null,
        message: 'No active meal slot right now.',
      });
    }

    const estimatedWaitMinutes = slot.current_token_number * 2;

    return res.status(200).json({
      active: true,
      slot: {
        id:                   slot.id,
        slot_name:            slot.slot_name,
        start_time:           slot.start_time,
        end_time:             slot.end_time,
        current_token_number: slot.current_token_number,
        now_serving:          slot.now_serving,
        date:                 slot.date,
      },
      estimated_wait_minutes: estimatedWaitMinutes,
    });
  } catch (err) {
    logger.error('getSlotStatus error:', err);
    return res.status(500).json({ error: 'Failed to fetch slot status' });
  }
};

// ─── POST /api/v1/pre-order ────────────────────────────────────────────────
export const createPreOrder = async (req, res) => {
  const client = await getClient();
  try {
    const { meal_slot, items, notes, pickup_time } = req.body;
    const userId = req.user.id;
    const today = new Date().toISOString().split('T')[0];

    // 1. Check student profile completeness
    const userRes = await client.query(
      `SELECT id, name, email, department, year, section FROM users WHERE id = $1`,
      [userId]
    );
    const user = userRes.rows[0];
    if (!user) return res.status(404).json({ error: 'User not found' });

    if (!user.department || !user.year || !user.section) {
      return res.status(422).json({
        error: 'profile_incomplete',
        message: 'Please complete your profile (department, year, section) before placing a pre-order.',
        missing_fields: [
          !user.department && 'department',
          !user.year && 'year',
          !user.section && 'section',
        ].filter(Boolean),
      });
    }

    // 2. Resolve / create slot
    let slot = await client.query(
      `SELECT * FROM meal_slots WHERE slot_name = $1 AND date = $2`,
      [meal_slot, today]
    );
    let slotRow = slot.rows[0];
    if (!slotRow) {
      // Create slot row if missing
      const created = await createSlotForToday(meal_slot);
      slotRow = await (await client.query(
        `SELECT * FROM meal_slots WHERE id = $1 FOR UPDATE`,
        [created.id]
      )).rows[0];
    } else {
      // Lock the slot row for atomic token counter update
      const locked = await client.query(
        `SELECT * FROM meal_slots WHERE id = $1 FOR UPDATE`,
        [slotRow.id]
      );
      slotRow = locked.rows[0];
    }

    // 3. Validate each item's capacity and collect details
    await client.query('BEGIN');

    const soldOutItems = [];
    const itemDetails = [];
    let totalItems = 0;

    for (const orderItem of items) {
      const { menu_item_id, quantity } = orderItem;

      // Get menu item info
      const menuRes = await client.query(
        `SELECT id, name, price, pre_order_limit, is_active FROM menu_items WHERE id = $1`,
        [menu_item_id]
      );
      const menuItem = menuRes.rows[0];
      if (!menuItem || !menuItem.is_active) {
        await client.query('ROLLBACK');
        return res.status(404).json({ error: `Menu item ${menu_item_id} not found or inactive` });
      }

      // Get current booking (lock row)
      const bookingRes = await client.query(
        `SELECT COALESCE(pob.booked_quantity, 0) AS booked_quantity
         FROM menu_items mi
         LEFT JOIN pre_order_bookings pob
           ON pob.menu_item_id = mi.id
           AND pob.meal_slot_id = $2
           AND pob.date = $3
         WHERE mi.id = $1`,
        [menu_item_id, slotRow.id, today]
      );
      const booked = parseInt(bookingRes.rows[0]?.booked_quantity || 0);
      const remaining = menuItem.pre_order_limit - booked;

      if (remaining < quantity) {
        soldOutItems.push({
          menu_item_id,
          name:      menuItem.name,
          remaining: Math.max(0, remaining),
          requested: quantity,
        });
      }

      itemDetails.push({
        menu_item_id,
        name:     menuItem.name,
        price:    parseFloat(menuItem.price),
        quantity,
        subtotal: parseFloat(menuItem.price) * quantity,
      });
      totalItems += quantity;
    }

    // 4. If ANY item capacity failed → rollback + 409
    if (soldOutItems.length > 0) {
      await client.query('ROLLBACK');
      return res.status(409).json({
        error: 'capacity_exceeded',
        message: 'One or more items do not have enough pre-order capacity.',
        sold_out_items: soldOutItems,
      });
    }

    // 5. Calculate token range
    const tokenStart = slotRow.current_token_number + 1;
    const tokenEnd   = slotRow.current_token_number + totalItems;
    const totalAmount = itemDetails.reduce((sum, i) => sum + i.subtotal, 0);

    // 6. Update slot token counter
    await client.query(
      `UPDATE meal_slots SET current_token_number = $1 WHERE id = $2`,
      [tokenEnd, slotRow.id]
    );

    // 7. Create order
    const orderRes = await client.query(
      `INSERT INTO orders (
         user_id, items, total_amount, time_slot, notes, status,
         token_number, meal_slot_id, department, year, section,
         total_items, pickup_time, order_type
       )
       VALUES ($1, $2, $3, $4, $5, 'pending', $6, $7, $8, $9, $10, $11, $12, 'pre_order')
       RETURNING *`,
      [
        userId,
        JSON.stringify(itemDetails),
        totalAmount,
        meal_slot,
        notes || null,
        tokenEnd,
        slotRow.id,
        user.department,
        user.year,
        user.section,
        totalItems,
        pickup_time || null,
      ]
    );
    const order = orderRes.rows[0];

    // 8. Create token_audit record
    await createAudit(client, order.id, tokenStart, tokenEnd, slotRow.id);

    // 9. Update pre_order_bookings for each item
    for (const orderItem of items) {
      await incrementBooking(client, orderItem.menu_item_id, slotRow.id, orderItem.quantity, today);
    }

    // 10. Commit
    await client.query('COMMIT');

    // 11. Emit socket events
    try {
      const io = getIO();
      const estimatedWait = (tokenEnd - slotRow.now_serving) * 2;

      // Notify the specific student
      io.to(`user:${userId}`).emit('order:tokenGenerated', {
        orderId:       order.id,
        tokenNumber:   tokenEnd,
        tokenStart,
        tokenEnd,
        mealSlot:      meal_slot,
        estimatedWait: Math.max(0, estimatedWait),
      });

      // Notify all clients about capacity changes
      for (const orderItem of items) {
        const cap = await getItemCapacity(orderItem.menu_item_id, slotRow.id, today);
        if (cap) {
          const payload = {
            itemId:    orderItem.menu_item_id,
            remaining: cap.remaining,
            status:    cap.status,
            mealSlot:  meal_slot,
          };
          if (cap.status === 'sold_out') {
            io.emit('pre_order:soldOut', {
              itemId:   orderItem.menu_item_id,
              itemName: itemDetails.find(i => i.menu_item_id === orderItem.menu_item_id)?.name,
              mealSlot: meal_slot,
            });
          }
          io.emit('pre_order:capacityUpdate', payload);
        }
      }
    } catch (socketErr) {
      logger.warn('Socket emit error (non-fatal):', socketErr.message);
    }

    return res.status(201).json({
      message: 'Pre-order placed successfully',
      order: {
        id:           order.id,
        token_number: order.token_number,
        token_start:  tokenStart,
        token_end:    tokenEnd,
        meal_slot:    meal_slot,
        status:       order.status,
        total_items:  totalItems,
        total_amount: totalAmount,
        items:        itemDetails,
        pickup_time:  order.pickup_time,
        notes:        order.notes,
        department:   order.department,
        year:         order.year,
        section:      order.section,
        created_at:   order.created_at,
      },
    });
  } catch (err) {
    try { await client.query('ROLLBACK'); } catch (_) {}
    logger.error('createPreOrder error:', err);
    return res.status(500).json({ error: 'Failed to place pre-order' });
  } finally {
    client.release();
  }
};

// ─── GET /api/v1/orders/my-tokens ──────────────────────────────────────────
export const getMyTokens = async (req, res) => {
  try {
    const userId = req.user.id;
    const result = await query(
      `SELECT
         o.*,
         ms.slot_name,
         ms.start_time AS slot_start_time,
         ms.end_time   AS slot_end_time,
         ms.now_serving,
         ta.token_start,
         ta.token_end
       FROM orders o
       JOIN meal_slots ms   ON ms.id = o.meal_slot_id
       JOIN token_audit ta  ON ta.order_id = o.id
       WHERE o.user_id = $1 AND o.order_type = 'pre_order'
       ORDER BY o.created_at DESC`,
      [userId]
    );

    const tokens = result.rows.map((row) => ({
      id:           row.id,
      token_number: row.token_number,
      token_start:  row.token_start,
      token_end:    row.token_end,
      meal_slot: {
        name:        row.slot_name,
        start_time:  row.slot_start_time,
        end_time:    row.slot_end_time,
        now_serving: row.now_serving,
      },
      department:   row.department,
      year:         row.year,
      section:      row.section,
      items:        typeof row.items === 'string' ? JSON.parse(row.items) : row.items,
      total_items:  row.total_items,
      total_amount: parseFloat(row.total_amount),
      pickup_time:  row.pickup_time,
      notes:        row.notes,
      status:       row.status,
      created_at:   row.created_at,
    }));

    return res.status(200).json({ tokens });
  } catch (err) {
    logger.error('getMyTokens error:', err);
    return res.status(500).json({ error: 'Failed to fetch your tokens' });
  }
};

// ─── GET /api/v1/orders/:id/token-receipt ──────────────────────────────────
export const getTokenReceipt = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const result = await query(
      `SELECT
         o.*,
         u.name AS student_name,
         ms.slot_name,
         ms.start_time AS slot_start_time,
         ms.end_time   AS slot_end_time,
         ms.now_serving,
         ta.token_start,
         ta.token_end
       FROM orders o
       JOIN users u          ON u.id  = o.user_id
       JOIN meal_slots ms    ON ms.id = o.meal_slot_id
       JOIN token_audit ta   ON ta.order_id = o.id
       WHERE o.id = $1 AND o.order_type = 'pre_order'`,
      [id]
    );

    if (!result.rows[0]) {
      return res.status(404).json({ error: 'Token receipt not found' });
    }

    const row = result.rows[0];

    // Only the owner or admin can view
    if (row.user_id !== userId && req.user.role !== 'admin') {
      return res.status(403).json({ error: 'Access denied' });
    }

    const items = typeof row.items === 'string' ? JSON.parse(row.items) : row.items;
    const estimatedWait = Math.max(0, (row.token_end - row.now_serving) * 2);

    return res.status(200).json({
      receipt: {
        order_id:       row.id,
        token_number:   row.token_number,
        token_start:    row.token_start,
        token_end:      row.token_end,
        student_name:   row.student_name,
        department:     row.department,
        year:           row.year,
        section:        row.section,
        meal_slot_name: row.slot_name,
        slot_start_time: row.slot_start_time,
        slot_end_time:   row.slot_end_time,
        items,
        total_amount:   parseFloat(row.total_amount),
        total_items:    row.total_items,
        pickup_time:    row.pickup_time,
        notes:          row.notes,
        status:         row.status,
        order_date:     row.created_at,
        estimated_wait_minutes: estimatedWait,
      },
    });
  } catch (err) {
    logger.error('getTokenReceipt error:', err);
    return res.status(500).json({ error: 'Failed to fetch token receipt' });
  }
};

// ─── PATCH /api/v1/pre-order/cancel/:orderId ───────────────────────────────
export const cancelPreOrder = async (req, res) => {
  const client = await getClient();
  try {
    const { orderId } = req.params;
    const userId = req.user.id;
    const today = new Date().toISOString().split('T')[0];

    await client.query('BEGIN');

    // Fetch order with lock
    const orderRes = await client.query(
      `SELECT o.*, ta.token_start, ta.token_end
       FROM orders o
       JOIN token_audit ta ON ta.order_id = o.id
       WHERE o.id = $1 FOR UPDATE`,
      [orderId]
    );
    const order = orderRes.rows[0];

    if (!order) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Order not found' });
    }

    // Only the owner can cancel (or admin)
    if (order.user_id !== userId && req.user.role !== 'admin') {
      await client.query('ROLLBACK');
      return res.status(403).json({ error: 'Access denied' });
    }

    if (order.status !== 'pending') {
      await client.query('ROLLBACK');
      return res.status(400).json({
        error: 'Cannot cancel order',
        message: `Order is in '${order.status}' status. Only pending orders can be cancelled.`,
      });
    }

    // Update order status
    await client.query(
      `UPDATE orders SET status = 'cancelled', updated_at = NOW() WHERE id = $1`,
      [orderId]
    );

    // Restore booked quantities — token counter is NOT touched
    const items = typeof order.items === 'string' ? JSON.parse(order.items) : order.items;
    for (const item of items) {
      await client.query(
        `UPDATE pre_order_bookings
         SET booked_quantity = GREATEST(0, booked_quantity - $1),
             updated_at = NOW()
         WHERE menu_item_id = $2 AND meal_slot_id = $3 AND date = $4`,
        [item.quantity, item.menu_item_id, order.meal_slot_id, today]
      );
    }

    await client.query('COMMIT');

    // Emit capacity updates
    try {
      const io = getIO();
      io.emit('order:statusUpdate', { orderId, status: 'cancelled' });

      for (const item of items) {
        const cap = await getItemCapacity(item.menu_item_id, order.meal_slot_id, today);
        if (cap) {
          io.emit('pre_order:capacityUpdate', {
            itemId:    item.menu_item_id,
            remaining: cap.remaining,
            status:    cap.status,
            mealSlot:  order.time_slot,
          });
        }
      }
    } catch (socketErr) {
      logger.warn('Socket emit error (non-fatal):', socketErr.message);
    }

    return res.status(200).json({
      message: 'Pre-order cancelled successfully. Token numbers are retained.',
      order_id: orderId,
      status: 'cancelled',
    });
  } catch (err) {
    try { await client.query('ROLLBACK'); } catch (_) {}
    logger.error('cancelPreOrder error:', err);
    return res.status(500).json({ error: 'Failed to cancel pre-order' });
  } finally {
    client.release();
  }
};
