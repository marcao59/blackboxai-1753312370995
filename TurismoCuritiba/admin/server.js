const express = require('express');
const bodyParser = require('body-parser');
const session = require('express-session');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

// Import routes
const authRoutes = require('./routes/auth');
const contentRoutes = require('./routes/content');
const dashboardRoutes = require('./routes/dashboard');

const app = express();

// Set up EJS as the view engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Middleware
app.use(cors());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(express.static(path.join(__dirname, 'public')));

// Session configuration
app.use(session({
  secret: process.env.SESSION_SECRET || 'turismo_curitiba_admin_secret_key_2024',
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: false, // Set to true in production with HTTPS
    maxAge: 24 * 60 * 60 * 1000 // 24 hours
  }
}));

// Authentication middleware
const requireAuth = (req, res, next) => {
  if (req.session && req.session.adminId) {
    return next();
  } else {
    return res.redirect('/auth/login');
  }
};

// Routes
app.use('/auth', authRoutes);
app.use('/dashboard', requireAuth, dashboardRoutes);
app.use('/api', requireAuth, contentRoutes);

// Root route - redirect to dashboard or login
app.get('/', (req, res) => {
  if (req.session && req.session.adminId) {
    res.redirect('/dashboard');
  } else {
    res.redirect('/auth/login');
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    service: 'Turismo Curitiba Admin Panel'
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).render('error', {
    title: 'Página não encontrada',
    message: 'A página que você está procurando não existe.',
    error: { status: 404 }
  });
});

// Global error handling middleware
app.use((err, req, res, next) => {
  console.error('Error occurred:', err);
  
  // Don't leak error details in production
  const isDevelopment = process.env.NODE_ENV !== 'production';
  
  res.status(err.status || 500).render('error', {
    title: 'Erro no servidor',
    message: isDevelopment ? err.message : 'Ocorreu um erro interno no servidor.',
    error: isDevelopment ? err : { status: err.status || 500 }
  });
});

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`🚀 Servidor do painel administrativo iniciado na porta ${PORT}`);
  console.log(`📱 Acesse: http://localhost:${PORT}`);
  console.log(`🔧 Ambiente: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
