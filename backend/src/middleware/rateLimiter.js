import rateLimit from 'express-rate-limit';

// General API rate limiter: 100 requests per minute
export const generalLimiter = rateLimit({
  windowMs: 60 * 1000, 
  limit: 100,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: { error: 'Too many requests, please try again later.' }
});

// Auth endpoints rate limiter: 5 requests per minute
export const authLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 5,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: { error: 'Too many auth requests, please try again later.' }
});

// Order creation rate limiter: 10 requests per minute
export const orderLimiter = rateLimit({
  windowMs: 60 * 1000,
  limit: 10,
  standardHeaders: 'draft-7',
  legacyHeaders: false,
  message: { error: 'Too many order requests, please try again later.' }
});
