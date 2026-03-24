import 'package:equatable/equatable.dart';
import 'artist_model.dart';

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
    };
  }

  @override
  List<Object?> get props => [id, title, externalId, artistId, description, releaseDate, coverImageUrl, tags, isOverride, artist];
}
