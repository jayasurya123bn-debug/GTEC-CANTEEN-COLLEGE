import admin from '../config/firebase.js';
import logger from '../utils/logger.js';

export const sendPushNotification = async (token, title, body, data = {}) => {
  try {
    if (!admin.apps.length) return; // Ignore if not initialized
    const message = {
      notification: { title, body },
      data,
      token,
    };
    await admin.messaging().send(message);
    logger.info(`Push notification sent to token: ${token}`);
  } catch (error) {
    logger.error(`Error sending push notification: ${error.message}`);
  }
};

export const sendMulticastPushNotification = async (tokens, title, body, data = {}) => {
  try {
    if (!admin.apps.length || tokens.length === 0) return;
    const message = {
      notification: { title, body },
      data,
      tokens,
    };
    const response = await admin.messaging().sendMulticast(message);
    logger.info(`Multicast push notification sent. Success: ${response.successCount}, Failure: ${response.failureCount}`);
  } catch (error) {
    logger.error(`Error sending multicast push notification: ${error.message}`);
  }
};
