import Joi from 'joi';

export const registerSchema = Joi.object({
  name: Joi.string().min(3).max(255).required(),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  phone: Joi.string().min(10).max(15).optional(),
});

export const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

export const refreshSchema = Joi.object({
  refreshToken: Joi.string().required(),
});

export const updateProfileSchema = Joi.object({
  name: Joi.string().min(3).max(255).optional(),
  phone: Joi.string().min(10).max(15).optional(),
});

export const updateFcmTokenSchema = Joi.object({
  fcm_token: Joi.string().required(),
});
