import Joi from 'joi';

export const updateStatusSchema = Joi.object({
  is_open: Joi.boolean().optional(),
  busyness: Joi.string().valid('low', 'moderate', 'high', 'packed').optional(),
}).min(1);

export const updateBroadcastSchema = Joi.object({
  broadcast_message: Joi.string().allow('', null).required(),
});
