import 'package:soundtilo/domain/entities/playlist_track_entity.dart';

class PlaylistTrackModel extends PlaylistTrackEntity {
  const PlaylistTrackModel({
    required super.trackExternalId,
    required super.position,
    required super.addedAt,
  });

  factory PlaylistTrackModel.fromJson(Map<String, dynamic> json) {
    return PlaylistTrackModel(
      trackExternalId: json['trackExternalId']?.toString() ?? '',
      position: json['position'] ?? 0,
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
    );
  }
}
