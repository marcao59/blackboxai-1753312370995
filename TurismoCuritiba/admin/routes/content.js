const express = require('express');
const router = express.Router();
const contentController = require('../controllers/contentController');

// Tourist Points Routes
router.get('/tourist-points', contentController.getTouristPoints);
router.get('/tourist-points/:id', contentController.getTouristPoint);
router.post('/tourist-points', contentController.upload.array('images', 5), contentController.createTouristPoint);
router.put('/tourist-points/:id', contentController.upload.array('images', 5), contentController.updateTouristPoint);
router.delete('/tourist-points/:id', contentController.deleteTouristPoint);

// Events Routes
router.get('/events', contentController.getEvents);
router.post('/events', contentController.upload.array('images', 5), contentController.createEvent);

// Image management
router.delete('/images', contentController.deleteImage);

// Statistics
router.get('/statistics', contentController.getStatistics);

module.exports = router;
