import { query } from '../config/database.js';

export const createOrder = async (userId, items, totalAmount, timeSlot, notes) => {
  const result = await query(`
    INSERT INTO orders (user_id, items, total_amount, time_slot, notes)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING *
  `, [userId, JSON.stringify(items), totalAmount, timeSlot, notes]);
  return result.rows[0];
};

export const getOrdersByUser = async (userId, limit = 10, offset = 0) => {
  const result = await query(`
    SELECT * FROM orders 
    WHERE user_id = $1 
    ORDER BY created_at DESC 
    LIMIT $2 OFFSET $3
  `, [userId, limit, offset]);
  
  const countResult = await query('SELECT COUNT(*) FROM orders WHERE user_id = $1', [userId]);
  
  return {
    orders: result.rows,
    total: parseInt(countResult.rows[0].count)
  };
};

export const getOrderById = async (id) => {
  const result = await query(`
    SELECT o.*, u.name as user_name, u.phone 
    FROM orders o
    JOIN users u ON o.user_id = u.id
    WHERE o.id = $1
  `, [id]);
  return result.rows[0];
};

export const getAllOrders = async ({ status }) => {
  let sql = `
    SELECT o.*, u.name as user_name 
    FROM orders o
    JOIN users u ON o.user_id = u.id
  `;
  const params = [];
  
  if (status) {
    sql += ` WHERE o.status = $1`;
    params.push(status);
  }
  
  sql += ` ORDER BY o.created_at DESC`;
  
  const result = await query(sql, params);
  return result.rows;
};

export const updateOrderStatus = async (id, status) => {
  const result = await query(`
    UPDATE orders 
    SET status = $1, updated_at = CURRENT_TIMESTAMP
    WHERE id = $2
    RETURNING *
  `, [status, id]);
  return result.rows[0];
};

export const getDashboardStats = async () => {
  const stats = {
    total_items: 0,
    orders_today: 0,
    revenue_today: 0,
    avg_rating: 0,
    orders_by_status: {
      pending: 0,
      ready: 0,
      completed: 0
    }
  };

  // Total items
  const itemsRes = await query('SELECT COUNT(*) FROM menu_items WHERE is_active = true');
  stats.total_items = parseInt(itemsRes.rows[0].count);

  // Today's stats
  const todayRes = await query(`
    SELECT COUNT(*) as count, COALESCE(SUM(total_amount), 0) as revenue 
    FROM orders 
    WHERE DATE(created_at) = CURRENT_DATE
  `);
  stats.orders_today = parseInt(todayRes.rows[0].count);
  stats.revenue_today = parseFloat(todayRes.rows[0].revenue);

  // Avg rating
  const ratingRes = await query('SELECT COALESCE(AVG(avg_rating), 0) as avg FROM menu_items WHERE is_active = true AND rating_count > 0');
  stats.avg_rating = parseFloat(ratingRes.rows[0].avg);

  // Status counts
  const statusRes = await query(`
    SELECT status, COUNT(*) 
    FROM orders 
    WHERE DATE(created_at) = CURRENT_DATE 
    GROUP BY status
  `);
  statusRes.rows.forEach(row => {
    stats.orders_by_status[row.status] = parseInt(row.count);
  });

  return stats;
};

export const getRecentOrders = async (limit = 10) => {
  const result = await query(`
    SELECT o.id, o.total_amount, o.status, o.created_at, u.name as user_name 
    FROM orders o
    JOIN users u ON o.user_id = u.id
    ORDER BY o.created_at DESC
    LIMIT $1
  `, [limit]);
  return result.rows;
};
