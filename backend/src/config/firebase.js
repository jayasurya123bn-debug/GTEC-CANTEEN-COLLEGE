import admin from 'firebase-admin';
import dotenv from 'dotenv';
import logger from '../utils/logger.js';

dotenv.config();

try {
  // Read from env for the private key
  const privateKey = process.env.FIREBASE_PRIVATE_KEY
    ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n')
    : undefined;

  admin.initializeApp({
    credential: admin.credential.cert({
      projectId: process.env.FIREBASE_PROJECT_ID,
      clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
      privateKey: privateKey,
    })
  });
  logger.info('Firebase Admin initialized');
} catch (error) {
  logger.error('Firebase Admin initialization error (may be ignored in dev without valid creds)', error);
}

export default admin;
