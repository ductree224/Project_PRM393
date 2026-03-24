import 'package:soundtilo/domain/entities/track_entity.dart';

class LocalAlbum {
  final String id;
  final String title;
  final String artistName;
  final String coverImageUrl;
  final List<TrackEntity> tracks;
  final int totalDurationSeconds;

  LocalAlbum({
    required this.id,
    required this.title,
    required this.artistName,
    required this.coverImageUrl,
    required List<TrackEntity> tracks,
  }) : tracks = List.unmodifiable(tracks),
       totalDurationSeconds = tracks.fold(0, (sum, t) => sum + t.durationSeconds);

  String get formattedTotalDuration {
    final minutes = totalDurationSeconds ~/ 60;
    final seconds = totalDurationSeconds % 60;
    return '$minutes min ${seconds.toString().padLeft(2, '0')} sec';
  }
}
