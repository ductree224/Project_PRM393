import 'package:soundtilo/domain/entities/playlist_entity.dart';

class PlaylistModel extends PlaylistEntity {
  const PlaylistModel({
    required super.id,
    required super.name,
    super.description,
    super.isPublic,
    super.trackCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      isPublic: json['isPublic'] ?? false,
      trackCount: json['trackCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isPublic': isPublic,
      'trackCount': trackCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
