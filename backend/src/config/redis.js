import Redis from 'ioredis';
import dotenv from 'dotenv';
import logger from '../utils/logger.js';

dotenv.config();

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

const redisClient = new Redis(redisUrl);

redisClient.on('connect', () => {
  logger.info('Connected to Redis');
});

redisClient.on('error', (err) => {
  logger.error('Redis Client Error', err);
});

export default redisClient;
