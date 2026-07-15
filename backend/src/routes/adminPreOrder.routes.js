import express from 'express';
import { authenticateToken, requireRole } from '../middleware/auth.js';
import { validateRequest } from '../middleware/validation.js';
import {
  updateLimitSchema,
  updateNowServingSchema,
  adminUpdatePreOrderStatusSchema,
  resetSlotSchema,
} from '../validators/preOrder.validator.js';
import {
  getDashboard,
  getPreOrders,
  updatePreOrderStatus,
  updatePreOrderLimit,
  resetMealSlot,
  getTokenQueue,
  setNowServing,
} from '../controllers/adminPreOrder.controller.js';

const router = express.Router();

// All routes require admin authentication
router.use(authenticateToken, requireRole(['admin']));

/**
 * GET /api/v1/admin/pre-order/dashboard
 * Real-time dashboard: slot info, stats, per-item capacity, department summary.
 */
router.get('/pre-order/dashboard', getDashboard);

/**
 * GET /api/v1/admin/pre-order/orders?meal_slot=lunch&status=pending&department=CSE
 * Filterable, sortable order list.
 */
router.get('/pre-order/orders', getPreOrders);

/**
 * PATCH /api/v1/admin/pre-order/:orderId/status
 * Update a pre-order's status with valid transition checks.
 */
router.patch(
  '/pre-order/:orderId/status',
  validateRequest(adminUpdatePreOrderStatusSchema),
  updatePreOrderStatus
);

/**
 * PATCH /api/v1/admin/menu/:itemId/pre-order-limit
 * Update a menu item's pre-order capacity limit in real-time.
 */
router.patch(
  '/menu/:itemId/pre-order-limit',
  validateRequest(updateLimitSchema),
  updatePreOrderLimit
);

/**
 * POST /api/v1/admin/meal-slot/reset
 * Reset a slot's token counter and clear all bookings (destructive).
 */
router.post(
  '/meal-slot/reset',
  validateRequest(resetSlotSchema),
  resetMealSlot
);

/**
 * GET /api/v1/admin/token-queue?meal_slot=lunch
 * Full token queue for current or specified slot.
 */
router.get('/token-queue', getTokenQueue);

/**
 * PATCH /api/v1/admin/token-queue/now-serving
 * Update the "now serving" token number and emit socket event.
 */
router.patch(
  '/token-queue/now-serving',
  validateRequest(updateNowServingSchema),
  setNowServing
);

export default router;
