import express from 'express';
import { getStats, getRecentOrdersList, listAllOrders, updateStatus } from '../controllers/admin.controller.js';
import { validateRequest } from '../middleware/validation.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';
import { updateOrderStatusSchema } from '../validators/order.validator.js';

const router = express.Router();

router.use(authenticateToken, requireRole(['admin']));

router.get('/stats', getStats);
router.get('/stats/recent-orders', getRecentOrdersList);
router.get('/orders', listAllOrders);
router.patch('/orders/:id/status', validateRequest(updateOrderStatusSchema), updateStatus);

export default router;
