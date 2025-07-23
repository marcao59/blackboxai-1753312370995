const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');

// GET /auth/login - Show login page
router.get('/login', authController.showLogin);

// POST /auth/login - Handle login
router.post('/login', authController.login);

// GET /auth/logout - Handle logout
router.get('/logout', authController.logout);

// GET /auth/register - Show register page (only for super admins)
router.get('/register', authController.showRegister);

// POST /auth/register - Handle admin registration (only for super admins)
router.post('/register', authController.register);

// POST /auth/change-password - Change password
router.post('/change-password', authController.changePassword);

module.exports = router;
