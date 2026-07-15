import express from 'express';
import { authenticateToken, requireRole } from '../middleware/auth.js';
import { validateRequest } from '../middleware/validation.js';
import {
  createPreOrderSchema,
} from '../validators/preOrder.validator.js';
import {
  getAvailableItems,
  getSlotStatus,
  createPreOrder,
  getMyTokens,
  getTokenReceipt,
  cancelPreOrder,
} from '../controllers/preOrder.controller.js';

const router = express.Router();

// All pre-order student routes require authentication
router.use(authenticateToken);

/**
 * GET /api/v1/pre-order/available?meal_slot=lunch
 * Returns all items with pre-order capacity info for the given (or current) slot.
 */
router.get(
  '/available',
  requireRole(['student', 'user', 'admin']),
  getAvailableItems
);

/**
 * GET /api/v1/pre-order/slot-status
 * Returns current active slot info and estimated wait time.
 */
router.get(
  '/slot-status',
  requireRole(['student', 'user', 'admin']),
  getSlotStatus
);

/**
 * POST /api/v1/pre-order
 * Place a pre-order. Atomic transaction, capacity-checked.
 */
router.post(
  '/',
  requireRole(['student', 'user', 'admin']),
  validateRequest(createPreOrderSchema),
  createPreOrder
);

/**
 * GET /api/v1/orders/my-tokens
 * Retrieve all pre-orders for the authenticated student.
 * Note: mounted under /orders in server.js so path is /orders/my-tokens
 */
router.get(
  '/my-tokens',
  requireRole(['student', 'user', 'admin']),
  getMyTokens
);

/**
 * GET /api/v1/orders/:id/token-receipt
 * Printable receipt data for a specific pre-order.
 */
router.get(
  '/:id/token-receipt',
  requireRole(['student', 'user', 'admin']),
  getTokenReceipt
);

/**
 * PATCH /api/v1/pre-order/cancel/:orderId
 * Cancel a pending pre-order. Restores capacity.
 */
router.patch(
  '/cancel/:orderId',
  requireRole(['student', 'user', 'admin']),
  cancelPreOrder
);

export default router;
