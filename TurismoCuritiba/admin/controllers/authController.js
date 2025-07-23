const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { db } = require('../firebase-config');

// Default admin credentials (in production, these should be in environment variables)
const DEFAULT_ADMIN = {
  email: 'admin@turismocuritiba.com',
  password: 'admin123', // This will be hashed
  name: 'Administrador',
  role: 'super_admin'
};

class AuthController {
  // Show login page
  async showLogin(req, res) {
    try {
      // If already logged in, redirect to dashboard
      if (req.session && req.session.adminId) {
        return res.redirect('/dashboard');
      }
      
      res.render('auth/login', {
        title: 'Login - Turismo Curitiba Admin',
        error: null,
        success: null
      });
    } catch (error) {
      console.error('Error showing login page:', error);
      res.status(500).render('error', {
        title: 'Erro',
        message: 'Erro ao carregar página de login',
        error: error
      });
    }
  }

  // Handle login
  async login(req, res) {
    try {
      const { email, password } = req.body;

      if (!email || !password) {
        return res.render('auth/login', {
          title: 'Login - Turismo Curitiba Admin',
          error: 'Email e senha são obrigatórios',
          success: null
        });
      }

      // Check if this is the default admin login
      if (email === DEFAULT_ADMIN.email && password === DEFAULT_ADMIN.password) {
        // Create session for default admin
        req.session.adminId = 'default_admin';
        req.session.adminEmail = DEFAULT_ADMIN.email;
        req.session.adminName = DEFAULT_ADMIN.name;
        req.session.adminRole = DEFAULT_ADMIN.role;

        return res.redirect('/dashboard');
      }

      // Try to find admin in Firestore
      const adminsRef = db.collection('admins');
      const adminQuery = await adminsRef.where('email', '==', email).get();

      if (adminQuery.empty) {
        return res.render('auth/login', {
          title: 'Login - Turismo Curitiba Admin',
          error: 'Credenciais inválidas',
          success: null
        });
      }

      const adminDoc = adminQuery.docs[0];
      const adminData = adminDoc.data();

      // Verify password
      const isValidPassword = await bcrypt.compare(password, adminData.password);
      
      if (!isValidPassword) {
        return res.render('auth/login', {
          title: 'Login - Turismo Curitiba Admin',
          error: 'Credenciais inválidas',
          success: null
        });
      }

      // Check if admin is active
      if (!adminData.isActive) {
        return res.render('auth/login', {
          title: 'Login - Turismo Curitiba Admin',
          error: 'Conta desativada. Entre em contato com o administrador.',
          success: null
        });
      }

      // Create session
      req.session.adminId = adminDoc.id;
      req.session.adminEmail = adminData.email;
      req.session.adminName = adminData.name;
      req.session.adminRole = adminData.role;

      // Update last login
      await adminsRef.doc(adminDoc.id).update({
        lastLogin: new Date(),
        updatedAt: new Date()
      });

      res.redirect('/dashboard');

    } catch (error) {
      console.error('Login error:', error);
      res.render('auth/login', {
        title: 'Login - Turismo Curitiba Admin',
        error: 'Erro interno do servidor. Tente novamente.',
        success: null
      });
    }
  }

  // Handle logout
  async logout(req, res) {
    try {
      req.session.destroy((err) => {
        if (err) {
          console.error('Session destroy error:', err);
          return res.redirect('/dashboard');
        }
        
        res.clearCookie('connect.sid');
        res.redirect('/auth/login?message=logout_success');
      });
    } catch (error) {
      console.error('Logout error:', error);
      res.redirect('/dashboard');
    }
  }

  // Show register page (for creating new admins)
  async showRegister(req, res) {
    try {
      // Only super admins can create new admins
      if (req.session.adminRole !== 'super_admin') {
        return res.status(403).render('error', {
          title: 'Acesso Negado',
          message: 'Você não tem permissão para acessar esta página.',
          error: { status: 403 }
        });
      }

      res.render('auth/register', {
        title: 'Criar Administrador - Turismo Curitiba',
        error: null,
        success: null
      });
    } catch (error) {
      console.error('Error showing register page:', error);
      res.status(500).render('error', {
        title: 'Erro',
        message: 'Erro ao carregar página de registro',
        error: error
      });
    }
  }

  // Handle admin registration
  async register(req, res) {
    try {
      // Only super admins can create new admins
      if (req.session.adminRole !== 'super_admin') {
        return res.status(403).render('error', {
          title: 'Acesso Negado',
          message: 'Você não tem permissão para criar novos administradores.',
          error: { status: 403 }
        });
      }

      const { name, email, password, confirmPassword, role } = req.body;

      // Validation
      if (!name || !email || !password || !confirmPassword || !role) {
        return res.render('auth/register', {
          title: 'Criar Administrador - Turismo Curitiba',
          error: 'Todos os campos são obrigatórios',
          success: null
        });
      }

      if (password !== confirmPassword) {
        return res.render('auth/register', {
          title: 'Criar Administrador - Turismo Curitiba',
          error: 'As senhas não coincidem',
          success: null
        });
      }

      if (password.length < 6) {
        return res.render('auth/register', {
          title: 'Criar Administrador - Turismo Curitiba',
          error: 'A senha deve ter pelo menos 6 caracteres',
          success: null
        });
      }

      // Check if email already exists
      const adminsRef = db.collection('admins');
      const existingAdmin = await adminsRef.where('email', '==', email).get();

      if (!existingAdmin.empty) {
        return res.render('auth/register', {
          title: 'Criar Administrador - Turismo Curitiba',
          error: 'Este email já está em uso',
          success: null
        });
      }

      // Hash password
      const hashedPassword = await bcrypt.hash(password, 12);

      // Create admin document
      const adminData = {
        name: name.trim(),
        email: email.toLowerCase().trim(),
        password: hashedPassword,
        role: role,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
        createdBy: req.session.adminId
      };

      await adminsRef.add(adminData);

      res.render('auth/register', {
        title: 'Criar Administrador - Turismo Curitiba',
        error: null,
        success: 'Administrador criado com sucesso!'
      });

    } catch (error) {
      console.error('Registration error:', error);
      res.render('auth/register', {
        title: 'Criar Administrador - Turismo Curitiba',
        error: 'Erro interno do servidor. Tente novamente.',
        success: null
      });
    }
  }

  // Change password
  async changePassword(req, res) {
    try {
      const { currentPassword, newPassword, confirmNewPassword } = req.body;

      if (!currentPassword || !newPassword || !confirmNewPassword) {
        return res.json({
          success: false,
          message: 'Todos os campos são obrigatórios'
        });
      }

      if (newPassword !== confirmNewPassword) {
        return res.json({
          success: false,
          message: 'As novas senhas não coincidem'
        });
      }

      if (newPassword.length < 6) {
        return res.json({
          success: false,
          message: 'A nova senha deve ter pelo menos 6 caracteres'
        });
      }

      // Handle default admin
      if (req.session.adminId === 'default_admin') {
        if (currentPassword !== DEFAULT_ADMIN.password) {
          return res.json({
            success: false,
            message: 'Senha atual incorreta'
          });
        }

        // For default admin, we can't change the password in this demo
        return res.json({
          success: false,
          message: 'Não é possível alterar a senha do administrador padrão nesta demonstração'
        });
      }

      // Get admin from Firestore
      const adminDoc = await db.collection('admins').doc(req.session.adminId).get();
      
      if (!adminDoc.exists) {
        return res.json({
          success: false,
          message: 'Administrador não encontrado'
        });
      }

      const adminData = adminDoc.data();

      // Verify current password
      const isValidPassword = await bcrypt.compare(currentPassword, adminData.password);
      
      if (!isValidPassword) {
        return res.json({
          success: false,
          message: 'Senha atual incorreta'
        });
      }

      // Hash new password
      const hashedNewPassword = await bcrypt.hash(newPassword, 12);

      // Update password
      await db.collection('admins').doc(req.session.adminId).update({
        password: hashedNewPassword,
        updatedAt: new Date()
      });

      res.json({
        success: true,
        message: 'Senha alterada com sucesso!'
      });

    } catch (error) {
      console.error('Change password error:', error);
      res.json({
        success: false,
        message: 'Erro interno do servidor. Tente novamente.'
      });
    }
  }
}

module.exports = new AuthController();
