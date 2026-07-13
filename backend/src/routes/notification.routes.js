import express from 'express';
import { getNotifications, markAsRead, markAllAsRead } from '../controllers/notification.controller.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticateToken, requireRole(['student']));

router.get('/', getNotifications);
router.patch('/read-all', markAllAsRead);
router.patch('/:id/read', markAsRead);

export default router;
