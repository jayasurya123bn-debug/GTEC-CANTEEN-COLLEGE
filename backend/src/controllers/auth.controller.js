import { createUser, findUserByEmail, findUserById, updateFcmToken, updateProfile } from '../models/user.model.js';
import { hashPassword, verifyPassword, generateTokens } from '../utils/helpers.js';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

export const register = async (req, res, next) => {
  try {
    const { name, email, password, phone } = req.body;
    
    const existingUser = await findUserByEmail(email);
    if (existingUser) {
      return res.status(400).json({ error: 'Email already exists' });
    }

    const hashed = await hashPassword(password);
    const user = await createUser(name, email, hashed, phone);
    
    res.status(201).json({ message: 'User registered successfully', user });
  } catch (error) {
    next(error);
  }
};

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    
    const user = await findUserByEmail(email);
    if (!user || !user.is_active) {
      return res.status(401).json({ error: 'Invalid credentials or inactive account' });
    }

    const isValid = await verifyPassword(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const { accessToken, refreshToken } = generateTokens(user);
    
    const { password_hash, ...userWithoutPassword } = user;
    
    res.status(200).json({ 
      user: userWithoutPassword, 
      accessToken, 
      refreshToken 
    });
  } catch (error) {
    next(error);
  }
};

export const refresh = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    
    jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET, (err, decoded) => {
      if (err) {
        return res.status(401).json({ error: 'Invalid refresh token' });
      }
      
      // Generate new access token
      const accessToken = jwt.sign({ id: decoded.id, role: decoded.role }, process.env.JWT_SECRET, { expiresIn: '15m' });
      res.status(200).json({ accessToken });
    });
  } catch (error) {
    next(error);
  }
};

export const logout = async (req, res, next) => {
  // In a real app with token blacklisting, add token to Redis blacklist here.
  res.status(200).json({ message: 'Logged out successfully' });
};

export const getMe = async (req, res, next) => {
  try {
    const user = await findUserById(req.user.id);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(200).json({ user });
  } catch (error) {
    next(error);
  }
};

export const updateMe = async (req, res, next) => {
  try {
    const { name, phone } = req.body;
    const user = await updateProfile(req.user.id, name, phone);
    res.status(200).json({ user });
  } catch (error) {
    next(error);
  }
};

export const updateFcm = async (req, res, next) => {
  try {
    const { fcm_token } = req.body;
    await updateFcmToken(req.user.id, fcm_token);
    res.status(200).json({ message: 'Token updated' });
  } catch (error) {
    next(error);
  }
};
