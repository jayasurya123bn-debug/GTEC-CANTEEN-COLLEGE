import Redis from 'ioredis';
import dotenv from 'dotenv';
import logger from '../utils/logger.js';

dotenv.config();

const redisUrl = process.env.REDIS_URL;

let redisClient;
if (redisUrl) {
  redisClient = new Redis(redisUrl);
  redisClient.on('connect', () => logger.info('Connected to Redis'));
  redisClient.on('error', (err) => logger.error('Redis Client Error', err));
} else {
  redisClient = {
    get: async () => null,
    set: async () => null,
    keys: async () => [],
    del: async () => null,
    on: () => {},
  };
  logger.warn('Redis is disabled because REDIS_URL is not set.');
}

export default redisClient;
