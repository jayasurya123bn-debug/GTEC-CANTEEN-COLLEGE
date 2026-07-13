import express from 'express';
import { 
  getMenu, getCategories, getItem, createMenu, 
  updateMenu, changeAvailability, deleteMenu,
  getScheduled, schedule
} from '../controllers/menu.controller.js';
import { validateRequest } from '../middleware/validation.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';
import { menuItemSchema, updateAvailabilitySchema, scheduleMenuSchema } from '../validators/menu.validator.js';

const router = express.Router();

// Public routes
router.get('/', getMenu);
router.get('/categories', getCategories);
router.get('/:id', getItem);
router.get('/scheduled/:date', getScheduled);

// Admin routes
router.post('/', authenticateToken, requireRole(['admin']), validateRequest(menuItemSchema), createMenu);
router.put('/:id', authenticateToken, requireRole(['admin']), validateRequest(menuItemSchema), updateMenu);
router.patch('/:id/availability', authenticateToken, requireRole(['admin']), validateRequest(updateAvailabilitySchema), changeAvailability);
router.delete('/:id', authenticateToken, requireRole(['admin']), deleteMenu);
router.post('/schedule', authenticateToken, requireRole(['admin']), validateRequest(scheduleMenuSchema), schedule);

export default router;
