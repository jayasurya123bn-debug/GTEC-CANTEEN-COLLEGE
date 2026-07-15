import Joi from 'joi';

// ─── createPreOrder ────────────────────────────────────────────────────────

export const createPreOrderSchema = Joi.object({
  meal_slot: Joi.string()
    .valid('breakfast', 'lunch', 'snacks', 'dinner')
    .required()
    .messages({
      'any.only': 'meal_slot must be one of breakfast, lunch, snacks, dinner',
      'any.required': 'meal_slot is required',
    }),

  items: Joi.array()
    .items(
      Joi.object({
        menu_item_id: Joi.string().uuid({ version: 'uuidv4' }).required().messages({
          'string.guid': 'menu_item_id must be a valid UUID',
          'any.required': 'menu_item_id is required for each item',
        }),
        quantity: Joi.number().integer().min(1).max(20).required().messages({
          'number.min': 'quantity must be at least 1',
          'number.max': 'quantity cannot exceed 20 per item',
          'any.required': 'quantity is required for each item',
        }),
      })
    )
    .min(1)
    .max(10)
    .required()
    .messages({
      'array.min': 'Order must contain at least 1 item',
      'array.max': 'Order cannot have more than 10 distinct items',
      'any.required': 'items array is required',
    }),

  notes: Joi.string().max(200).allow('', null).optional().messages({
    'string.max': 'Notes cannot exceed 200 characters',
  }),

  pickup_time: Joi.string()
    .pattern(/^([01]\d|2[0-3]):[0-5]\d$/)
    .allow('', null)
    .optional()
    .messages({
      'string.pattern.base': 'pickup_time must be in HH:MM format (e.g. 12:30)',
    }),
});

// ─── updatePreOrderLimit ───────────────────────────────────────────────────

export const updateLimitSchema = Joi.object({
  pre_order_limit: Joi.number().integer().min(0).max(500).required().messages({
    'number.min': 'pre_order_limit cannot be negative',
    'number.max': 'pre_order_limit cannot exceed 500',
    'any.required': 'pre_order_limit is required',
  }),
});

// ─── updateNowServing ──────────────────────────────────────────────────────

export const updateNowServingSchema = Joi.object({
  token_number: Joi.number().integer().min(0).required().messages({
    'number.min': 'token_number cannot be negative',
    'any.required': 'token_number is required',
  }),
  slot_name: Joi.string()
    .valid('breakfast', 'lunch', 'snacks', 'dinner')
    .optional()
    .messages({
      'any.only': 'slot_name must be one of breakfast, lunch, snacks, dinner',
    }),
});

// ─── cancelPreOrder ────────────────────────────────────────────────────────

export const cancelPreOrderSchema = Joi.object({
  // no body required — orderId comes from URL param
}).optional();

// ─── adminUpdateOrderStatus ────────────────────────────────────────────────

export const adminUpdatePreOrderStatusSchema = Joi.object({
  status: Joi.string()
    .valid('confirmed', 'preparing', 'ready', 'completed', 'cancelled')
    .required()
    .messages({
      'any.only': 'status must be one of confirmed, preparing, ready, completed, cancelled',
      'any.required': 'status is required',
    }),
});

// ─── resetSlot ─────────────────────────────────────────────────────────────

export const resetSlotSchema = Joi.object({
  slot_name: Joi.string()
    .valid('breakfast', 'lunch', 'snacks', 'dinner')
    .required()
    .messages({
      'any.only': 'slot_name must be one of breakfast, lunch, snacks, dinner',
      'any.required': 'slot_name is required',
    }),
});
