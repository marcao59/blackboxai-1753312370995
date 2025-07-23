const express = require('express');
const router = express.Router();

// Dashboard home
router.get('/', async (req, res) => {
  try {
    res.render('dashboard/index', {
      title: 'Dashboard - Turismo Curitiba Admin',
      adminName: req.session.adminName,
      adminRole: req.session.adminRole,
      currentPage: 'dashboard'
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).render('error', {
      title: 'Erro',
      message: 'Erro ao carregar dashboard',
      error: error
    });
  }
});

// Tourist Points Management
router.get('/tourist-points', async (req, res) => {
  try {
    res.render('dashboard/tourist-points', {
      title: 'Pontos Turísticos - Turismo Curitiba Admin',
      adminName: req.session.adminName,
      adminRole: req.session.adminRole,
      currentPage: 'tourist-points'
    });
  } catch (error) {
    console.error('Tourist points page error:', error);
    res.status(500).render('error', {
      title: 'Erro',
      message: 'Erro ao carregar página de pontos turísticos',
      error: error
    });
  }
});

// Add Tourist Point
router.get('/tourist-points/add', async (req, res) => {
  try {
    res.render('dashboard/add-tourist-point', {
      title: 'Adicionar Ponto Turístico - Turismo Curitiba Admin',
      adminName: req.session.adminName,
      adminRole: req.session.adminRole,
      currentPage: 'tourist-points'
    });
  } catch (error) {
    console.error('Add tourist point page error:', error);
    res.status(500).render('error', {
      title: 'Erro',
      message: 'Erro ao carregar página de adicionar ponto turístico',
      error: error
    });
  }
});

// Edit Tourist Point
router.get('/tourist-points/edit/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    res.render('dashboard/edit-tourist-point', {
      title: 'Editar Ponto Turístico - Turismo Curitiba Admin',
      adminName: req.session.adminName,
      adminRole: req.session.adminRole,
      currentPage: 'tourist-points',
      pointId: id
    });
  } catch (error) {
    console.error('Edit tourist point page error:', error);
    res.status(500).render('error', {
      title: 'Erro',
      message: 'Erro ao carregar página de editar ponto turístico',
      error: error
    });
  }
});

// Events Management
router.get('/events', async (req, res) => {
  try {
    res.render('dashboard/events', {
      title: 'Eventos - Turismo Curitiba Admin',
      adminName: req.session.adminName,
      adminRole: req.session.adminRole,
      currentPage: 'events'
    });
  } catch (error) {
    console.error('Events page error:', error);
    res.status(500).render('error', {
      title: 'Erro',
      message: 'Erro ao carregar página de eventos',
      error: error
    });
  }
});

// Add Event
router.get('/events/add', async (req, res) => {
  try {
    res.render('dashboard/add-event', {
      title: 'Adicionar Evento - Turismo Curitiba Admin',
      adminName: req.session.adminName,
      adminRole: req.session.adminRole,
      currentPage: 'events'
    });
  } catch (error) {
    console.error('Add event page error:', error);
    res.status(500).render('error', {
      title: 'Erro',
      message: 'Erro ao carregar página de adicionar evento',
      error: error
    });
  }
});

// Users Management
router.get('/users', async (req, res) => {
  try {
    res.render('dashboard/users', {
      title: 'Usuários - Turismo Curitiba Admin',
      adminName: req.session.adminName,
      adminRole: req.session.adminRole,
      currentPage: 'users'
    });
  } catch (error) {
    console.error('Users page error:', error);
    res.status(500).render('error', {
      title: 'Erro',
      message: 'Erro ao carregar página de usuários',
      error: error
    });
  }
});

// Reviews Management
router.get('/reviews', async (req, res) => {
  try {
    res.render('dashboard/reviews', {
      title: 'Avaliações - Turismo Curitiba Admin',
      adminName: req.session.adminName,
      adminRole: req.session.adminRole,
      currentPage: 'reviews'
    });
  } catch (error) {
    console.error('Reviews page error:', error);
    res.status(500).render('error', {
      title: 'Erro',
      message: 'Erro ao carregar página de avaliações',
      error: error
    });
  }
});

// Settings
router.get('/settings', async (req, res) => {
  try {
    res.render('dashboard/settings', {
      title: 'Configurações - Turismo Curitiba Admin',
      adminName: req.session.adminName,
      adminRole: req.session.adminRole,
      currentPage: 'settings'
    });
  } catch (error) {
    console.error('Settings page error:', error);
    res.status(500).render('error', {
      title: 'Erro',
      message: 'Erro ao carregar página de configurações',
      error: error
    });
  }
});

module.exports = router;
