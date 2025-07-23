import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/tourist_point.dart';
import '../models/event.dart';
import '../models/user.dart';

class FirebaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collections
  static const String _touristPointsCollection = 'pontos_turisticos';
  static const String _eventsCollection = 'eventos';
  static const String _usersCollection = 'usuarios';
  static const String _reviewsCollection = 'avaliacoes';

  // Auth Methods
  Future<User?> getCurrentUser() async {
    try {
      return _auth.currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Tourist Points Methods
  Future<List<TouristPoint>> getTouristPoints({String? category}) async {
    try {
      Query query = _firestore
          .collection(_touristPointsCollection)
          .where('isActive', isEqualTo: true);

      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => TouristPoint.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting tourist points: $e');
      return [];
    }
  }

  Future<TouristPoint?> getTouristPointById(String id) async {
    try {
      final doc = await _firestore
          .collection(_touristPointsCollection)
          .doc(id)
          .get();

      if (doc.exists) {
        return TouristPoint.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting tourist point by id: $e');
      return null;
    }
  }

  Future<List<TouristPoint>> getNearbyTouristPoints(
      double latitude, double longitude, double radiusKm) async {
    try {
      // Simple implementation - in production, use GeoFlutterFire for better geoqueries
      final allPoints = await getTouristPoints();
      
      return allPoints.where((point) {
        final distance = _calculateDistance(
            latitude, longitude, point.latitude, point.longitude);
        return distance <= radiusKm;
      }).toList();
    } catch (e) {
      print('Error getting nearby tourist points: $e');
      return [];
    }
  }

  // Events Methods
  Future<List<Event>> getEvents({bool? isFeatured}) async {
    try {
      Query query = _firestore
          .collection(_eventsCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('startDate', descending: false);

      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }

      final querySnapshot = await query.get();
      
      return querySnapshot.docs
          .map((doc) => Event.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error getting events: $e');
      return [];
    }
  }

  Future<Event?> getEventById(String id) async {
    try {
      final doc = await _firestore
          .collection(_eventsCollection)
          .doc(id)
          .get();

      if (doc.exists) {
        return Event.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting event by id: $e');
      return null;
    }
  }

  // User Methods
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(AppUser user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Future<bool> createUserProfile(AppUser user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toMap());
      return true;
    } catch (e) {
      print('Error creating user profile: $e');
      return false;
    }
  }

  Future<bool> addToFavorites(String userId, String pointId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'favoritePoints': FieldValue.arrayUnion([pointId]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error adding to favorites: $e');
      return false;
    }
  }

  Future<bool> removeFromFavorites(String userId, String pointId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'favoritePoints': FieldValue.arrayRemove([pointId]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error removing from favorites: $e');
      return false;
    }
  }

  Future<bool> addToVisited(String userId, String pointId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'visitedPoints': FieldValue.arrayUnion([pointId]),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      print('Error adding to visited: $e');
      return false;
    }
  }

  // Reviews Methods
  Future<bool> addReview(String pointId, String userId, double rating, String comment) async {
    try {
      final reviewData = {
        'pointId': pointId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      };

      await _firestore
          .collection(_reviewsCollection)
          .add(reviewData);

      // Update tourist point rating
      await _updateTouristPointRating(pointId);
      
      return true;
    } catch (e) {
      print('Error adding review: $e');
      return false;
    }
  }

  Future<void> _updateTouristPointRating(String pointId) async {
    try {
      final reviews = await _firestore
          .collection(_reviewsCollection)
          .where('pointId', isEqualTo: pointId)
          .get();

      if (reviews.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviews.docs) {
          totalRating += (doc.data()['rating'] ?? 0.0).toDouble();
        }

        final averageRating = totalRating / reviews.docs.length;
        
        await _firestore
            .collection(_touristPointsCollection)
            .doc(pointId)
            .update({
          'rating': averageRating,
          'reviewCount': reviews.docs.length,
          'updatedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (e) {
      print('Error updating tourist point rating: $e');
    }
  }

  // Utility Methods
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula for calculating distance between two points
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    
    final double a = 
        (dLat / 2).sin() * (dLat / 2).sin() +
        lat1.cos() * lat2.cos() *
        (dLon / 2).sin() * (dLon / 2).sin();
    
    final double c = 2 * a.sqrt().asin();
    
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (3.14159265359 / 180);
  }

  // Search Methods
  Future<List<TouristPoint>> searchTouristPoints(String query, String languageCode) async {
    try {
      final allPoints = await getTouristPoints();
      
      return allPoints.where((point) {
        final name = point.getLocalizedName(languageCode).toLowerCase();
        final description = point.getLocalizedDescription(languageCode).toLowerCase();
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) || description.contains(searchQuery);
      }).toList();
    } catch (e) {
      print('Error searching tourist points: $e');
      return [];
    }
  }
}
