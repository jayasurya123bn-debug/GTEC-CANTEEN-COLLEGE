import express from 'express';
import { register, login, refresh, logout, getMe, updateMe, updateFcm } from '../controllers/auth.controller.js';
import { validateRequest } from '../middleware/validation.js';
import { authenticateToken } from '../middleware/auth.js';
import { authLimiter } from '../middleware/rateLimiter.js';
import { registerSchema, loginSchema, refreshSchema, updateProfileSchema, updateFcmTokenSchema } from '../validators/auth.validator.js';

const router = express.Router();

router.post('/register', authLimiter, validateRequest(registerSchema), register);
router.post('/login', authLimiter, validateRequest(loginSchema), login);
router.post('/refresh', authLimiter, validateRequest(refreshSchema), refresh);
router.post('/logout', authenticateToken, validateRequest(refreshSchema), logout);
router.get('/me', authenticateToken, getMe);
router.put('/me', authenticateToken, validateRequest(updateProfileSchema), updateMe);
router.put('/fcm-token', authenticateToken, validateRequest(updateFcmTokenSchema), updateFcm);

export default router;
