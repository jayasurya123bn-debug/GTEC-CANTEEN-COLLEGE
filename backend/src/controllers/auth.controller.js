import { createUser, findUserByEmail, findUserById, updateFcmToken, updateProfile } from '../models/user.model.js';
import { hashPassword, verifyPassword, generateTokens } from '../utils/helpers.js';
import { query } from '../config/database.js';
import { registerSchema } from '../validators/auth.validator.js';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import dotenv from 'dotenv';

dotenv.config();

export const register = async (req, res, next) => {
  try {
    // 1. Validate with registerSchema
    const { error, value } = registerSchema.validate(req.body, { abortEarly: false });
    if (error) {
      const errorMessage = error.details.map((detail) => detail.message).join(', ');
      return res.status(400).json({ success: false, message: errorMessage });
    }

    const { name, email, password, department, year, section } = value;

    // 2. Check if email exists
    const existingUser = await findUserByEmail(email);
    if (existingUser) {
      return res.status(409).json({ success: false, message: 'Email already exists' });
    }

    // 3. Hash password with bcryptjs (saltRounds: 12)
    const salt = await bcrypt.genSalt(12);
    const hashedPassword = await bcrypt.hash(password, salt);

    // 4. Insert into users table with role: 'student', including department, year, and section
    const result = await query(
      `INSERT INTO users (name, email, password_hash, department, year, section, role)
       VALUES ($1, $2, $3, $4, $5, $6, 'student')
       RETURNING id, name, email, department, year, section, role`,
      [name, email, hashedPassword, department, year, section]
    );
    const newUser = result.rows[0];

    // 5. Generate access and refresh tokens
    const { accessToken, refreshToken } = generateTokens(newUser);

    // 6. Return response
    return res.status(201).json({
      success: true,
      message: 'Registration successful',
      user: {
        id: newUser.id,
        name: newUser.name,
        email: newUser.email,
        department: newUser.department,
        year: newUser.year,
        section: newUser.section,
        role: newUser.role,
      },
      accessToken,
      refreshToken,
    });
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
    
    jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET || 'fallback_super_refresh_key_123', (err, decoded) => {
      if (err) {
        return res.status(401).json({ error: 'Invalid refresh token' });
      }
      
      // Generate new access token
      const accessToken = jwt.sign({ id: decoded.id, role: decoded.role }, process.env.JWT_SECRET, { expiresIn: '7d' });
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
    const { name, phone, password } = req.body;
    let passwordHash = null;
    if (password && password.trim() !== '') {
      const salt = await bcrypt.genSalt(12);
      passwordHash = await bcrypt.hash(password, salt);
    }
    const user = await updateProfile(req.user.id, name, phone, passwordHash);
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
