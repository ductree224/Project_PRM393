import 'package:equatable/equatable.dart';

class TrackAdminModel extends Equatable {
  final String externalId;
  final String source;
  final String title;
  final String artistName;
  final String? albumName;
  final String? artworkUrl;
  final String status;
  final DateTime cachedAt;

  const TrackAdminModel({
    required this.externalId,
    required this.source,
    required this.title,
    required this.artistName,
    this.albumName,
    this.artworkUrl,
    required this.status,
    required this.cachedAt,
  });

  factory TrackAdminModel.fromJson(Map<String, dynamic> json) {
    return TrackAdminModel(
      externalId: json['externalId'] as String,
      source: json['source'] as String,
      title: json['title'] as String,
      artistName: json['artistName'] as String,
      albumName: json['albumName'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      status: json['status'] as String,
      cachedAt: DateTime.parse(json['cachedAt'] as String),
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
      'status': status,
      'cachedAt': cachedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        externalId,
        source,
        title,
        artistName,
        albumName,
        artworkUrl,
        status,
        cachedAt,
      ];
}
