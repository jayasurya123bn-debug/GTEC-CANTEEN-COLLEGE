import Joi from 'joi';

export const menuItemSchema = Joi.object({
  category_id: Joi.string().uuid().required(),
  name: Joi.string().min(3).max(255).required(),
  description: Joi.string().optional().allow('', null),
  price: Joi.number().positive().precision(2).required(),
  image_url: Joi.string().uri().optional().allow('', null),
  // is_veg is intentionally omitted here to prevent injection
  dietary_tag: Joi.string().valid('veg', 'vegan').default('veg'),
  availability: Joi.string().valid('available', 'limited', 'sold_out').default('available'),
  limited_quantity: Joi.number().integer().min(0).optional().allow(null),
});

export const updateAvailabilitySchema = Joi.object({
  availability: Joi.string().valid('available', 'limited', 'sold_out').required(),
  limited_quantity: Joi.number().integer().min(0).optional().allow(null),
});

export const reviewSchema = Joi.object({
  rating: Joi.number().integer().min(1).max(5).required(),
  comment: Joi.string().optional().allow('', null),
});

export const approveReviewSchema = Joi.object({
  is_approved: Joi.boolean().required(),
});

export const scheduleMenuSchema = Joi.object({
  item_id: Joi.string().uuid().required(),
  scheduled_date: Joi.date().iso().required(),
  meal_type: Joi.string().required(),
});
