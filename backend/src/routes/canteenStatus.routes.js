import express from 'express';
import { getCanteenStatus, updateCanteenStatus, setBroadcast } from '../controllers/canteenStatus.controller.js';
import { validateRequest } from '../middleware/validation.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';
import { updateStatusSchema, updateBroadcastSchema } from '../validators/canteen.validator.js';

const router = express.Router();

router.get('/status', getCanteenStatus);
router.put('/status', authenticateToken, requireRole(['admin']), validateRequest(updateStatusSchema), updateCanteenStatus);
router.put('/broadcast', authenticateToken, requireRole(['admin']), validateRequest(updateBroadcastSchema), setBroadcast);

export default router;
