import 'package:equatable/equatable.dart';

class Event extends Equatable {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final List<String> imageUrls;
  final DateTime startDate;
  final DateTime endDate;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String category;
  final bool isFeatured;
  final bool isActive;
  final String? ticketUrl;
  final Map<String, String>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.startDate,
    required this.endDate,
    this.location,
    this.latitude,
    this.longitude,
    required this.category,
    this.isFeatured = false,
    this.isActive = true,
    this.ticketUrl,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromMap(Map<String, dynamic> map, String id) {
    return Event(
      id: id,
      title: Map<String, String>.from(map['title'] ?? {}),
      description: Map<String, String>.from(map['description'] ?? {}),
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      startDate: DateTime.fromMillisecondsSinceEpoch(map['startDate'] ?? 0),
      endDate: DateTime.fromMillisecondsSinceEpoch(map['endDate'] ?? 0),
      location: map['location'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      category: map['category'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      isActive: map['isActive'] ?? true,
      ticketUrl: map['ticketUrl'],
      additionalInfo: map['additionalInfo'] != null 
          ? Map<String, String>.from(map['additionalInfo']) 
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrls': imageUrls,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'category': category,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'ticketUrl': ticketUrl,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  String getLocalizedTitle(String languageCode) {
    return title[languageCode] ?? title['pt'] ?? title.values.first;
  }

  String getLocalizedDescription(String languageCode) {
    return description[languageCode] ?? description['pt'] ?? description.values.first;
  }

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }

  bool get isPast {
    return DateTime.now().isAfter(endDate);
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrls,
        startDate,
        endDate,
        location,
        latitude,
        longitude,
        category,
        isFeatured,
        isActive,
        ticketUrl,
        additionalInfo,
        createdAt,
        updatedAt,
      ];
}
