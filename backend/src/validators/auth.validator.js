import Joi from 'joi';

export const registerSchema = Joi.object({
  name: Joi.string().trim().min(3).max(50).required().messages({
    'string.empty': 'Full name is required',
    'string.min': 'Name must be at least 3 characters'
  }),
  email: Joi.string().email().required(),
  password: Joi.string().min(6).required(),
  department: Joi.string().valid('CSE', 'ECE', 'EEE', 'MECH', 'CIVIL', 'IT', 'AI&DS', 'BME', 'CHEM').required().messages({
    'any.only': 'Select a valid department',
    'string.empty': 'Department is required'
  }),
  year: Joi.string().valid('1st Year', '2nd Year', '3rd Year', '4th Year').required().messages({
    'any.only': 'Select a valid year',
    'string.empty': 'Year is required'
  }),
  section: Joi.string().valid('A', 'B', 'C', 'D').required().messages({
    'any.only': 'Select a valid section',
    'string.empty': 'Section is required'
  })
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
  phone: Joi.string().min(10).max(15).optional().allow(''),
  password: Joi.string().min(6).optional().allow(''),
});

export const updateFcmTokenSchema = Joi.object({
  fcm_token: Joi.string().required(),
});
