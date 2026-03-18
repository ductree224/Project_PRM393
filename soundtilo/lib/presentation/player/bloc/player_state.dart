import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';

enum PlayerStatus { idle, loading, playing, paused, error }

class PlayerState extends Equatable {
  final TrackEntity? currentTrack;
  final List<TrackEntity> queue;
  final int currentIndex;
  final PlayerStatus status;
  final Duration position;
  final Duration duration;
  final String? errorMessage;
  final bool isFavorite;

  const PlayerState({
    this.currentTrack,
    this.queue = const [],
    this.currentIndex = 0,
    this.status = PlayerStatus.idle,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.errorMessage,
    this.isFavorite = false,
  });

  PlayerState copyWith({
    TrackEntity? currentTrack,
    List<TrackEntity>? queue,
    int? currentIndex,
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
    String? errorMessage,
    bool? isFavorite,
  }) {
    return PlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      errorMessage: errorMessage ?? this.errorMessage,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  bool get hasNext => currentIndex < queue.length - 1;
  bool get hasPrevious => currentIndex > 0;

  @override
  List<Object?> get props =>
      [currentTrack, queue, currentIndex, status, position, duration, errorMessage, isFavorite];
}
