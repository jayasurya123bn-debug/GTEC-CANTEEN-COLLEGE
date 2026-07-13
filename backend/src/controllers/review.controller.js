import { getReviewsByItemId, createReview, getAllReviews, updateReviewStatus, deleteReview as removeReview } from '../models/review.model.js';
import { updateItemRating } from '../models/menuItem.model.js';
import { getIO } from '../services/socket.service.js';

export const getReviews = async (req, res, next) => {
  try {
    const { page = 1, limit = 10 } = req.query;
    const offset = (page - 1) * limit;
    const data = await getReviewsByItemId(req.params.id, limit, offset);
    res.status(200).json({ ...data, page, pages: Math.ceil(data.total / limit) });
  } catch (error) {
    next(error);
  }
};

export const submitReview = async (req, res, next) => {
  try {
    const { rating, comment } = req.body;
    await createReview(req.params.id, req.user.id, rating, comment);
    res.status(201).json({ message: 'Review submitted for approval' });
  } catch (error) {
    next(error);
  }
};

export const listAllReviews = async (req, res, next) => {
  try {
    let { approved, item_id } = req.query;
    if (approved !== undefined) approved = approved === 'true';
    const reviews = await getAllReviews({ is_approved: approved, item_id });
    res.status(200).json({ reviews });
  } catch (error) {
    next(error);
  }
};

export const approveReview = async (req, res, next) => {
  try {
    const { is_approved } = req.body;
    const review = await updateReviewStatus(req.params.id, is_approved);
    
    if (is_approved) {
      // Update item average rating
      await updateItemRating(review.item_id, review.rating);
      
      // Emit socket event for real-time review ticker
      getIO().emit('review:new', {
        itemId: review.item_id,
        userName: review.user_name || 'Student',
        rating: review.rating,
        comment: review.comment,
        createdAt: review.created_at
      });
    }
    
    res.status(200).json({ message: 'Review approved' });
  } catch (error) {
    next(error);
  }
};

export const deleteReview = async (req, res, next) => {
  try {
    await removeReview(req.params.id);
    res.status(200).json({ message: 'Review deleted' });
  } catch (error) {
    next(error);
  }
};
