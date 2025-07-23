import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String preferredLanguage;
  final List<String> favoritePoints;
  final List<String> visitedPoints;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.preferredLanguage = 'pt',
    this.favoritePoints = const [],
    this.visitedPoints = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      name: map['name'],
      photoUrl: map['photoUrl'],
      preferredLanguage: map['preferredLanguage'] ?? 'pt',
      favoritePoints: List<String>.from(map['favoritePoints'] ?? []),
      visitedPoints: List<String>.from(map['visitedPoints'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'preferredLanguage': preferredLanguage,
      'favoritePoints': favoritePoints,
      'visitedPoints': visitedPoints,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  AppUser copyWith({
    String? email,
    String? name,
    String? photoUrl,
    String? preferredLanguage,
    List<String>? favoritePoints,
    List<String>? visitedPoints,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      favoritePoints: favoritePoints ?? this.favoritePoints,
      visitedPoints: visitedPoints ?? this.visitedPoints,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool isFavorite(String pointId) {
    return favoritePoints.contains(pointId);
  }

  bool hasVisited(String pointId) {
    return visitedPoints.contains(pointId);
  }

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        photoUrl,
        preferredLanguage,
        favoritePoints,
        visitedPoints,
        createdAt,
        updatedAt,
      ];
}
