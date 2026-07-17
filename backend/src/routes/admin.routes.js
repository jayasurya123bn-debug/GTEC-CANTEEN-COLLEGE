import express from 'express';
import { getStats, getRecentOrdersList, listAllOrders, updateStatus, getStudents } from '../controllers/admin.controller.js';
import { validateRequest } from '../middleware/validation.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';
import { updateOrderStatusSchema } from '../validators/order.validator.js';

const router = express.Router();

router.use(authenticateToken, requireRole(['admin']));

router.get('/stats', getStats);
router.get('/stats/recent-orders', getRecentOrdersList);
router.get('/orders', listAllOrders);
router.patch('/orders/:id/status', validateRequest(updateOrderStatusSchema), updateStatus);
router.get('/students', getStudents);

export default router;
