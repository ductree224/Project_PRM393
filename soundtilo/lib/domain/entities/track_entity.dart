import 'package:equatable/equatable.dart';

class TrackEntity extends Equatable {
  final String externalId;
  final String source; // 'audius' | 'deezer' | 'jamendo'
  final String title;
  final String artistName;
  final String? albumName;
  final String? artworkUrl;
  final String? streamUrl;
  final String? previewUrl;
  final int durationSeconds;
  final String? genre;
  final String? mood;
  final int playCount;

  const TrackEntity({
    required this.externalId,
    required this.source,
    required this.title,
    required this.artistName,
    this.albumName,
    this.artworkUrl,
    this.streamUrl,
    this.previewUrl,
    required this.durationSeconds,
    this.genre,
    this.mood,
    this.playCount = 0,
  });

  /// Whether this track can be fully streamed (Audius/Jamendo) or only 30s preview (Deezer)
  bool get isFullStream => source == 'audius' || source == 'jamendo';

  /// Get the playable URL — prefer stream, fallback to preview
  String? get playableUrl => streamUrl ?? previewUrl;

  /// Format duration as mm:ss
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [externalId, source, title, artistName];
}
