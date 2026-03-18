import 'package:soundtilo/data/models/playlist_track_model.dart';
import 'package:soundtilo/domain/entities/playlist_detail_entity.dart';

class PlaylistDetailModel extends PlaylistDetailEntity {
  const PlaylistDetailModel({
    required super.id,
    required super.name,
    super.description,
    super.coverImageUrl,
    required super.isPublic,
    required super.tracks,
    required super.createdAt,
    required super.updatedAt,
  });

  factory PlaylistDetailModel.fromJson(Map<String, dynamic> json) {
    final tracks =
        (json['tracks'] as List?)
            ?.whereType<Map>()
            .map(
              (item) =>
                  PlaylistTrackModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(growable: false) ??
        const <PlaylistTrackModel>[];

    return PlaylistDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      coverImageUrl: json['coverImageUrl'],
      isPublic: json['isPublic'] ?? false,
      tracks: tracks,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}
