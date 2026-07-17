import logger from '../utils/logger.js';

const CACHE_TTL = 3600; // 1 hour

export const getCache = async (key) => {
  return null;
};

export const setCache = async (key, value, ttl = CACHE_TTL) => {
  // No-op
};

export const invalidateCache = async (pattern) => {
  // No-op
};

