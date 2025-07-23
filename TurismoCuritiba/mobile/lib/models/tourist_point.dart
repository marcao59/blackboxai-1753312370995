import 'package:equatable/equatable.dart';

class TouristPoint extends Equatable {
  final String id;
  final Map<String, String> name;
  final Map<String, String> description;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final String category;
  final double rating;
  final int reviewCount;
  final Map<String, String> address;
  final String? phone;
  final String? website;
  final Map<String, String>? openingHours;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TouristPoint({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.address,
    this.phone,
    this.website,
    this.openingHours,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TouristPoint.fromMap(Map<String, dynamic> map, String id) {
    return TouristPoint(
      id: id,
      name: Map<String, String>.from(map['name'] ?? {}),
      description: Map<String, String>.from(map['description'] ?? {}),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      address: Map<String, String>.from(map['address'] ?? {}),
      phone: map['phone'],
      website: map['website'],
      openingHours: map['openingHours'] != null 
          ? Map<String, String>.from(map['openingHours']) 
          : null,
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrls': imageUrls,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'address': address,
      'phone': phone,
      'website': website,
      'openingHours': openingHours,
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  String getLocalizedName(String languageCode) {
    return name[languageCode] ?? name['pt'] ?? name.values.first;
  }

  String getLocalizedDescription(String languageCode) {
    return description[languageCode] ?? description['pt'] ?? description.values.first;
  }

  String getLocalizedAddress(String languageCode) {
    return address[languageCode] ?? address['pt'] ?? address.values.first;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrls,
        latitude,
        longitude,
        category,
        rating,
        reviewCount,
        address,
        phone,
        website,
        openingHours,
        isActive,
        createdAt,
        updatedAt,
      ];
}
