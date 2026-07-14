import express from 'express';
import { createOrder, getMyOrders, getOrder } from '../controllers/order.controller.js';
import { validateRequest } from '../middleware/validation.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';
import { orderLimiter } from '../middleware/rateLimiter.js';
import { orderSchema } from '../validators/order.validator.js';

const router = express.Router();

router.use(authenticateToken);

// Student and Admin
router.post('/', requireRole(['student', 'user', 'admin']), orderLimiter, validateRequest(orderSchema), createOrder);
router.get('/', requireRole(['student', 'user', 'admin']), getMyOrders);

// Both Student and Admin
router.get('/:id', getOrder);

export default router;
