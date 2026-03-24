import 'package:equatable/equatable.dart';

class ArtistModel extends Equatable {
  final String id;
  final String name;
  final String? externalId;
  final String? bio;
  final String? imageUrl;
  final List<String> tags;
  final bool isOverride;

  const ArtistModel({
    required this.id,
    required this.name,
    this.externalId,
    this.bio,
    this.imageUrl,
    this.tags = const [],
    this.isOverride = false,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'] as String,
      name: json['name'] as String,
      externalId: json['externalId'] as String?,
      bio: json['bio'] as String?,
      imageUrl: json['imageUrl'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isOverride: json['isOverride'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'externalId': externalId,
      'bio': bio,
      'imageUrl': imageUrl,
      'tags': tags,
      'isOverride': isOverride,
    };
  }

  @override
  List<Object?> get props => [id, name, externalId, bio, imageUrl, tags, isOverride];
}
