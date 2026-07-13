import pkg from 'pg';
const { Pool } = pkg;
import dotenv from 'dotenv';
import logger from '../utils/logger.js';

dotenv.config();

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

pool.on('error', (err, client) => {
  logger.error('Unexpected error on idle client', err);
  process.exit(-1);
});

export const query = (text, params) => pool.query(text, params);
export const getClient = () => pool.connect();
