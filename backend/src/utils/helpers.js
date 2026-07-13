import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

export const hashPassword = async (password) => {
  const salt = await bcrypt.genSalt(12);
  return bcrypt.hash(password, salt);
};

export const verifyPassword = async (password, hash) => {
  return bcrypt.compare(password, hash);
};

export const generateTokens = (user) => {
  const payload = {
    id: user.id,
    role: user.role,
  };

  const accessToken = jwt.sign(payload, process.env.JWT_SECRET, {
    expiresIn: '15m',
  });

  const refreshToken = jwt.sign(payload, process.env.JWT_REFRESH_SECRET, {
    expiresIn: '7d',
  });

  return { accessToken, refreshToken };
};
