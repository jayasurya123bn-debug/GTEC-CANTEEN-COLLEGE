import Joi from 'joi';

export const orderSchema = Joi.object({
  items: Joi.array().items(
    Joi.object({
      item_id: Joi.string().uuid().required(),
      quantity: Joi.number().integer().min(1).required(),
      price: Joi.number().positive().required(),
    })
  ).min(1).required(),
  time_slot: Joi.string().required(),
  notes: Joi.string().optional().allow('', null),
});

export const updateOrderStatusSchema = Joi.object({
  status: Joi.string().valid('pending', 'confirmed', 'preparing', 'ready', 'completed', 'cancelled').required(),
});
