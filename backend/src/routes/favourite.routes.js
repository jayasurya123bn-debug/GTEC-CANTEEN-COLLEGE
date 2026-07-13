import express from 'express';
import { listFavourites, addFav, removeFav, checkFav } from '../controllers/favourite.controller.js';
import { authenticateToken, requireRole } from '../middleware/auth.js';

const router = express.Router();

router.use(authenticateToken, requireRole(['student']));

router.get('/', listFavourites);
router.post('/:itemId', addFav);
router.delete('/:itemId', removeFav);
router.get('/check/:itemId', checkFav);

export default router;
