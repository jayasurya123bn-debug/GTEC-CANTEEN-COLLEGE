import redisClient from '../config/redis.js';
import logger from '../utils/logger.js';

const CACHE_TTL = 3600; // 1 hour

export const getCache = async (key) => {
  try {
    const data = await redisClient.get(key);
    return data ? JSON.parse(data) : null;
  } catch (error) {
    logger.error(`Redis Get Error for key ${key}: ${error.message}`);
    return null;
  }
};

export const setCache = async (key, value, ttl = CACHE_TTL) => {
  try {
    await redisClient.set(key, JSON.stringify(value), 'EX', ttl);
  } catch (error) {
    logger.error(`Redis Set Error for key ${key}: ${error.message}`);
  }
};

export const invalidateCache = async (pattern) => {
  try {
    const keys = await redisClient.keys(pattern);
    if (keys.length > 0) {
      await redisClient.del(...keys);
      logger.info(`Invalidated cache for pattern: ${pattern}`);
    }
  } catch (error) {
    logger.error(`Redis Invalidate Error for pattern ${pattern}: ${error.message}`);
  }
};
