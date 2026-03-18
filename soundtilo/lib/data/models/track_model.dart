import 'package:soundtilo/domain/entities/track_entity.dart';

class TrackModel extends TrackEntity {
  const TrackModel({
    required super.externalId,
    required super.source,
    required super.title,
    required super.artistName,
    super.albumName,
    super.artworkUrl,
    super.streamUrl,
    super.previewUrl,
    required super.durationSeconds,
    super.genre,
    super.mood,
    super.playCount,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      externalId: json['externalId'] ?? '',
      source: json['source'] ?? 'audius',
      title: json['title'] ?? 'Unknown',
      artistName: json['artistName'] ?? 'Unknown Artist',
      albumName: json['albumName'],
      artworkUrl: json['artworkUrl'],
      streamUrl: json['streamUrl'],
      previewUrl: json['previewUrl'],
      durationSeconds: json['durationSeconds'] ?? 0,
      genre: json['genre'],
      mood: json['mood'],
      playCount: json['playCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'externalId': externalId,
      'source': source,
      'title': title,
      'artistName': artistName,
      'albumName': albumName,
      'artworkUrl': artworkUrl,
      'streamUrl': streamUrl,
      'previewUrl': previewUrl,
      'durationSeconds': durationSeconds,
      'genre': genre,
      'mood': mood,
      'playCount': playCount,
    };
  }
}
