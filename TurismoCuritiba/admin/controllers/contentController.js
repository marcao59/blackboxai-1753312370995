const { db, bucket } = require('../firebase-config');
const multer = require('multer');
const path = require('path');

// Configure multer for file uploads
const storage = multer.memoryStorage();
const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png|gif|webp/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Apenas imagens são permitidas (JPEG, JPG, PNG, GIF, WebP)'));
    }
  }
});

class ContentController {
  constructor() {
    this.upload = upload;
  }

  // Tourist Points Management
  async getTouristPoints(req, res) {
    try {
      const { page = 1, limit = 10, category, search, status } = req.query;
      const offset = (page - 1) * limit;

      let query = db.collection('pontos_turisticos');

      // Apply filters
      if (category && category !== 'all') {
        query = query.where('category', '==', category);
      }

      if (status !== undefined) {
        query = query.where('isActive', '==', status === 'true');
      }

      // Get total count for pagination
      const totalSnapshot = await query.get();
      const total = totalSnapshot.size;

      // Get paginated results
      const snapshot = await query
        .orderBy('createdAt', 'desc')
        .limit(parseInt(limit))
        .offset(offset)
        .get();

      const points = [];
      snapshot.forEach(doc => {
        const data = doc.data();
        points.push({
          id: doc.id,
          ...data,
          createdAt: data.createdAt?.toDate(),
          updatedAt: data.updatedAt?.toDate()
        });
      });

      // Filter by search term if provided
      let filteredPoints = points;
      if (search) {
        const searchTerm = search.toLowerCase();
        filteredPoints = points.filter(point => {
          const nameMatch = Object.values(point.name || {}).some(name => 
            name.toLowerCase().includes(searchTerm)
          );
          const descMatch = Object.values(point.description || {}).some(desc => 
            desc.toLowerCase().includes(searchTerm)
          );
          return nameMatch || descMatch;
        });
      }

      res.json({
        success: true,
        data: filteredPoints,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: search ? filteredPoints.length : total,
          pages: Math.ceil((search ? filteredPoints.length : total) / limit)
        }
      });

    } catch (error) {
      console.error('Error getting tourist points:', error);
      res.status(500).json({
        success: false,
        message: 'Erro ao buscar pontos turísticos',
        error: error.message
      });
    }
  }

  async getTouristPoint(req, res) {
    try {
      const { id } = req.params;
      
      const doc = await db.collection('pontos_turisticos').doc(id).get();
      
      if (!doc.exists) {
        return res.status(404).json({
          success: false,
          message: 'Ponto turístico não encontrado'
        });
      }

      const data = doc.data();
      res.json({
        success: true,
        data: {
          id: doc.id,
          ...data,
          createdAt: data.createdAt?.toDate(),
          updatedAt: data.updatedAt?.toDate()
        }
      });

    } catch (error) {
      console.error('Error getting tourist point:', error);
      res.status(500).json({
        success: false,
        message: 'Erro ao buscar ponto turístico',
        error: error.message
      });
    }
  }

  async createTouristPoint(req, res) {
    try {
      const {
        name_pt, name_en, name_es,
        description_pt, description_en, description_es,
        address_pt, address_en, address_es,
        latitude, longitude, category, phone, website,
        opening_hours_pt, opening_hours_en, opening_hours_es
      } = req.body;

      // Validation
      if (!name_pt || !description_pt || !address_pt || !latitude || !longitude || !category) {
        return res.status(400).json({
          success: false,
          message: 'Campos obrigatórios: nome (PT), descrição (PT), endereço (PT), latitude, longitude e categoria'
        });
      }

      // Handle image uploads
      let imageUrls = [];
      if (req.files && req.files.length > 0) {
        imageUrls = await this.uploadImages(req.files, 'tourist-points');
      }

      const pointData = {
        name: {
          pt: name_pt,
          en: name_en || name_pt,
          es: name_es || name_pt
        },
        description: {
          pt: description_pt,
          en: description_en || description_pt,
          es: description_es || description_pt
        },
        address: {
          pt: address_pt,
          en: address_en || address_pt,
          es: address_es || address_pt
        },
        latitude: parseFloat(latitude),
        longitude: parseFloat(longitude),
        category: category,
        phone: phone || null,
        website: website || null,
        openingHours: opening_hours_pt || opening_hours_en || opening_hours_es ? {
          pt: opening_hours_pt || null,
          en: opening_hours_en || null,
          es: opening_hours_es || null
        } : null,
        imageUrls: imageUrls,
        rating: 0,
        reviewCount: 0,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
        createdBy: req.session.adminId
      };

      const docRef = await db.collection('pontos_turisticos').add(pointData);

      res.json({
        success: true,
        message: 'Ponto turístico criado com sucesso!',
        data: { id: docRef.id, ...pointData }
      });

    } catch (error) {
      console.error('Error creating tourist point:', error);
      res.status(500).json({
        success: false,
        message: 'Erro ao criar ponto turístico',
        error: error.message
      });
    }
  }

  async updateTouristPoint(req, res) {
    try {
      const { id } = req.params;
      const {
        name_pt, name_en, name_es,
        description_pt, description_en, description_es,
        address_pt, address_en, address_es,
        latitude, longitude, category, phone, website,
        opening_hours_pt, opening_hours_en, opening_hours_es,
        isActive
      } = req.body;

      // Check if point exists
      const doc = await db.collection('pontos_turisticos').doc(id).get();
      if (!doc.exists) {
        return res.status(404).json({
          success: false,
          message: 'Ponto turístico não encontrado'
        });
      }

      const currentData = doc.data();

      // Handle image uploads
      let imageUrls = currentData.imageUrls || [];
      if (req.files && req.files.length > 0) {
        const newImageUrls = await this.uploadImages(req.files, 'tourist-points');
        imageUrls = [...imageUrls, ...newImageUrls];
      }

      const updateData = {
        name: {
          pt: name_pt || currentData.name?.pt,
          en: name_en || currentData.name?.en || name_pt,
          es: name_es || currentData.name?.es || name_pt
        },
        description: {
          pt: description_pt || currentData.description?.pt,
          en: description_en || currentData.description?.en || description_pt,
          es: description_es || currentData.description?.es || description_pt
        },
        address: {
          pt: address_pt || currentData.address?.pt,
          en: address_en || currentData.address?.en || address_pt,
          es: address_es || currentData.address?.es || address_pt
        },
        latitude: latitude ? parseFloat(latitude) : currentData.latitude,
        longitude: longitude ? parseFloat(longitude) : currentData.longitude,
        category: category || currentData.category,
        phone: phone !== undefined ? phone : currentData.phone,
        website: website !== undefined ? website : currentData.website,
        openingHours: (opening_hours_pt || opening_hours_en || opening_hours_es) ? {
          pt: opening_hours_pt || currentData.openingHours?.pt,
          en: opening_hours_en || currentData.openingHours?.en,
          es: opening_hours_es || currentData.openingHours?.es
        } : currentData.openingHours,
        imageUrls: imageUrls,
        isActive: isActive !== undefined ? isActive === 'true' : currentData.isActive,
        updatedAt: new Date(),
        updatedBy: req.session.adminId
      };

      await db.collection('pontos_turisticos').doc(id).update(updateData);

      res.json({
        success: true,
        message: 'Ponto turístico atualizado com sucesso!',
        data: { id, ...updateData }
      });

    } catch (error) {
      console.error('Error updating tourist point:', error);
      res.status(500).json({
        success: false,
        message: 'Erro ao atualizar ponto turístico',
        error: error.message
      });
    }
  }

  async deleteTouristPoint(req, res) {
    try {
      const { id } = req.params;

      // Check if point exists
      const doc = await db.collection('pontos_turisticos').doc(id).get();
      if (!doc.exists) {
        return res.status(404).json({
          success: false,
          message: 'Ponto turístico não encontrado'
        });
      }

      // Soft delete - just mark as inactive
      await db.collection('pontos_turisticos').doc(id).update({
        isActive: false,
        deletedAt: new Date(),
        deletedBy: req.session.adminId
      });

      res.json({
        success: true,
        message: 'Ponto turístico removido com sucesso!'
      });

    } catch (error) {
      console.error('Error deleting tourist point:', error);
      res.status(500).json({
        success: false,
        message: 'Erro ao remover ponto turístico',
        error: error.message
      });
    }
  }

  // Events Management
  async getEvents(req, res) {
    try {
      const { page = 1, limit = 10, category, search, status } = req.query;
      const offset = (page - 1) * limit;

      let query = db.collection('eventos');

      // Apply filters
      if (category && category !== 'all') {
        query = query.where('category', '==', category);
      }

      if (status !== undefined) {
        query = query.where('isActive', '==', status === 'true');
      }

      // Get total count for pagination
      const totalSnapshot = await query.get();
      const total = totalSnapshot.size;

      // Get paginated results
      const snapshot = await query
        .orderBy('startDate', 'desc')
        .limit(parseInt(limit))
        .offset(offset)
        .get();

      const events = [];
      snapshot.forEach(doc => {
        const data = doc.data();
        events.push({
          id: doc.id,
          ...data,
          startDate: data.startDate?.toDate(),
          endDate: data.endDate?.toDate(),
          createdAt: data.createdAt?.toDate(),
          updatedAt: data.updatedAt?.toDate()
        });
      });

      // Filter by search term if provided
      let filteredEvents = events;
      if (search) {
        const searchTerm = search.toLowerCase();
        filteredEvents = events.filter(event => {
          const titleMatch = Object.values(event.title || {}).some(title => 
            title.toLowerCase().includes(searchTerm)
          );
          const descMatch = Object.values(event.description || {}).some(desc => 
            desc.toLowerCase().includes(searchTerm)
          );
          return titleMatch || descMatch;
        });
      }

      res.json({
        success: true,
        data: filteredEvents,
        pagination: {
          page: parseInt(page),
          limit: parseInt(limit),
          total: search ? filteredEvents.length : total,
          pages: Math.ceil((search ? filteredEvents.length : total) / limit)
        }
      });

    } catch (error) {
      console.error('Error getting events:', error);
      res.status(500).json({
        success: false,
        message: 'Erro ao buscar eventos',
        error: error.message
      });
    }
  }

  async createEvent(req, res) {
    try {
      const {
        title_pt, title_en, title_es,
        description_pt, description_en, description_es,
        startDate, endDate, location, latitude, longitude,
        category, isFeatured, ticketUrl
      } = req.body;

      // Validation
      if (!title_pt || !description_pt || !startDate || !endDate || !category) {
        return res.status(400).json({
          success: false,
          message: 'Campos obrigatórios: título (PT), descrição (PT), data início, data fim e categoria'
        });
      }

      // Handle image uploads
      let imageUrls = [];
      if (req.files && req.files.length > 0) {
        imageUrls = await this.uploadImages(req.files, 'events');
      }

      const eventData = {
        title: {
          pt: title_pt,
          en: title_en || title_pt,
          es: title_es || title_pt
        },
        description: {
          pt: description_pt,
          en: description_en || description_pt,
          es: description_es || description_pt
        },
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        location: location || null,
        latitude: latitude ? parseFloat(latitude) : null,
        longitude: longitude ? parseFloat(longitude) : null,
        category: category,
        isFeatured: isFeatured === 'true',
        ticketUrl: ticketUrl || null,
        imageUrls: imageUrls,
        isActive: true,
        createdAt: new Date(),
        updatedAt: new Date(),
        createdBy: req.session.adminId
      };

      const docRef = await db.collection('eventos').add(eventData);

      res.json({
        success: true,
        message: 'Evento criado com sucesso!',
        data: { id: docRef.id, ...eventData }
      });

    } catch (error) {
      console.error('Error creating event:', error);
      res.status(500).json({
        success: false,
        message: 'Erro ao criar evento',
        error: error.message
      });
    }
  }

  // Image upload helper
  async uploadImages(files, folder) {
    const imageUrls = [];

    for (const file of files) {
      try {
        const fileName = `${folder}/${Date.now()}-${Math.random().toString(36).substring(7)}-${file.originalname}`;
        const fileUpload = bucket.file(fileName);

        const stream = fileUpload.createWriteStream({
          metadata: {
            contentType: file.mimetype,
          },
        });

        await new Promise((resolve, reject) => {
          stream.on('error', reject);
          stream.on('finish', resolve);
          stream.end(file.buffer);
        });

        // Make file publicly accessible
        await fileUpload.makePublic();

        // Get public URL
        const publicUrl = `https://storage.googleapis.com/${bucket.name}/${fileName}`;
        imageUrls.push(publicUrl);

      } catch (error) {
        console.error('Error uploading image:', error);
        throw new Error(`Erro ao fazer upload da imagem: ${file.originalname}`);
      }
    }

    return imageUrls;
  }

  // Delete image
  async deleteImage(req, res) {
    try {
      const { imageUrl } = req.body;

      if (!imageUrl) {
        return res.status(400).json({
          success: false,
          message: 'URL da imagem é obrigatória'
        });
      }

      // Extract file name from URL
      const urlParts = imageUrl.split('/');
      const fileName = urlParts[urlParts.length - 1];

      // Delete from Firebase Storage
      await bucket.file(fileName).delete();

      res.json({
        success: true,
        message: 'Imagem removida com sucesso!'
      });

    } catch (error) {
      console.error('Error deleting image:', error);
      res.status(500).json({
        success: false,
        message: 'Erro ao remover imagem',
        error: error.message
      });
    }
  }

  // Get dashboard statistics
  async getStatistics(req, res) {
    try {
      // Get counts from different collections
      const [touristPointsSnapshot, eventsSnapshot, usersSnapshot, reviewsSnapshot] = await Promise.all([
        db.collection('pontos_turisticos').where('isActive', '==', true).get(),
        db.collection('eventos').where('isActive', '==', true).get(),
        db.collection('usuarios').get(),
        db.collection('avaliacoes').get()
      ]);

      const stats = {
        touristPoints: touristPointsSnapshot.size,
        events: eventsSnapshot.size,
        users: usersSnapshot.size,
        reviews: reviewsSnapshot.size
      };

      res.json({
        success: true,
        data: stats
      });

    } catch (error) {
      console.error('Error getting statistics:', error);
      res.status(500).json({
        success: false,
        message: 'Erro ao buscar estatísticas',
        error: error.message
      });
    }
  }
}

module.exports = new ContentController();
