import { query } from '../config/database.js';

export const createUser = async (name, email, passwordHash, phone) => {
  const result = await query(
    `INSERT INTO users (name, email, password_hash, phone)
     VALUES ($1, $2, $3, $4)
     RETURNING id, name, email, role, phone, avatar_url, is_active`,
    [name, email, passwordHash, phone]
  );
  return result.rows[0];
};

export const findUserByEmail = async (email) => {
  const result = await query('SELECT * FROM users WHERE email = $1', [email]);
  return result.rows[0];
};

export const findUserById = async (id) => {
  const result = await query('SELECT id, name, email, role, phone, avatar_url, is_active FROM users WHERE id = $1', [id]);
  return result.rows[0];
};

export const updateFcmToken = async (userId, fcmToken) => {
  await query('UPDATE users SET fcm_token = $1 WHERE id = $2', [fcmToken, userId]);
};

export const updateProfile = async (userId, name, phone) => {
  const result = await query(
    `UPDATE users SET name = COALESCE($1, name), phone = COALESCE($2, phone), updated_at = CURRENT_TIMESTAMP
     WHERE id = $3
     RETURNING id, name, email, role, phone, avatar_url`,
    [name, phone, userId]
  );
  return result.rows[0];
};
export const getAllStudents = async () => {
  const result = await query(
    `SELECT id, name, email, department, year, section, created_at 
     FROM users 
     WHERE role = 'student' 
     ORDER BY created_at DESC`
  );
  return result.rows;
};

export const deleteUserById = async (id) => {
  await query('DELETE FROM users WHERE id = $1', [id]);
};

