import express from 'express';
import { getReviews, submitReview, listAllReviews, approveReview, deleteReview } from '../controllers/review.controller.js';
import { validateRequest } from '../middleware/validation.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';
import { reviewSchema, approveReviewSchema } from '../validators/menu.validator.js';

const router = express.Router(); // Note: mounted at /api/v1/reviews but we might need /api/v1/menu/:id/reviews

// Public
router.get('/menu/:id', getReviews); // Mounts to /api/v1/reviews/menu/:id

// Student / User / Admin
router.post('/menu/:id', authenticateToken, requireRole(['student', 'user', 'admin']), validateRequest(reviewSchema), submitReview);

// Admin
router.get('/', authenticateToken, requireRole(['admin']), listAllReviews);
router.patch('/:id/approve', authenticateToken, requireRole(['admin']), validateRequest(approveReviewSchema), approveReview);
router.delete('/:id', authenticateToken, requireRole(['admin']), deleteReview);

export default router;
