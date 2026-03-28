import 'package:equatable/equatable.dart';
import 'artist_model.dart';
import 'track_model.dart';

class AlbumTrackModel extends Equatable {
  final String id;
  final String trackExternalId;
  final int position;
  final DateTime addedAt;
  final TrackModel? track;

  const AlbumTrackModel({
    required this.id,
    required this.trackExternalId,
    required this.position,
    required this.addedAt,
    this.track,
  });

  factory AlbumTrackModel.fromJson(Map<String, dynamic> json) {
    return AlbumTrackModel(
      id: json['id'] as String,
      trackExternalId: json['trackExternalId'] as String,
      position: json['position'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
      track: json['track'] != null ? TrackModel.fromJson(json['track']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackExternalId': trackExternalId,
      'position': position,
      'addedAt': addedAt.toIso8601String(),
      'track': track?.toJson(),
    };
  }

  @override
  List<Object?> get props => [id, trackExternalId, position, addedAt, track];
}

class AlbumModel extends Equatable {
  final String id;
  final String title;
  final String? externalId;
  final String? artistId;
  final String? description;
  final DateTime? releaseDate;
  final String? coverImageUrl;
  final List<String> tags;
  final bool isOverride;
  final ArtistModel? artist;
  final List<AlbumTrackModel> tracks;

  const AlbumModel({
    required this.id,
    required this.title,
    this.externalId,
    this.artistId,
    this.description,
    this.releaseDate,
    this.coverImageUrl,
    this.tags = const [],
    this.isOverride = false,
    this.artist,
    this.tracks = const [],
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      id: json['id'] as String,
      title: json['title'] as String,
      externalId: json['externalId'] as String?,
      artistId: json['artistId'] as String?,
      description: json['description'] as String?,
      releaseDate: json['releaseDate'] != null ? DateTime.tryParse(json['releaseDate']) : null,
      coverImageUrl: json['coverImageUrl'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      isOverride: json['isOverride'] as bool? ?? false,
      artist: json['artist'] != null ? ArtistModel.fromJson(json['artist']) : null,
      tracks: json['tracks'] != null ? List<AlbumTrackModel>.from((json['tracks'] as List).map((x) => AlbumTrackModel.fromJson(x))) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'externalId': externalId,
      'artistId': artistId,
      'description': description,
      'releaseDate': releaseDate?.toIso8601String(),
      'coverImageUrl': coverImageUrl,
      'tags': tags,
      'isOverride': isOverride,
      'artist': artist?.toJson(),
      'tracks': tracks.map((x) => x.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, title, externalId, artistId, description, releaseDate, coverImageUrl, tags, isOverride, artist, tracks];
}
