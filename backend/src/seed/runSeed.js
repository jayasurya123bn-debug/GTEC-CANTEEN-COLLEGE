import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { getClient } from '../config/database.js';
import logger from '../utils/logger.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const runSeed = async () => {
  const client = await getClient();
  try {
    const sqlPath = path.join(__dirname, '../../../docs/database_schema.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');
    
    logger.info('Starting database migration and seed...');
    await client.query(sql);
    logger.info('Database seeded successfully! 🌿');
    
  } catch (err) {
    logger.error('Error seeding database:', err);
  } finally {
    client.release();
    process.exit(0);
  }
};

runSeed();
