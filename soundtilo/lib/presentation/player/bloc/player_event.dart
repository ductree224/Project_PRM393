import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';

abstract class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

class PlayerPlay extends PlayerEvent {
  final TrackEntity track;
  final List<TrackEntity> queue;
  final int startIndex;

  const PlayerPlay({required this.track, this.queue = const [], this.startIndex = 0});

  @override
  List<Object?> get props => [track, queue, startIndex];
}

class PlayerResume extends PlayerEvent {}

class PlayerPause extends PlayerEvent {}

class PlayerStop extends PlayerEvent {}

class PlayerNext extends PlayerEvent {}

class PlayerPrevious extends PlayerEvent {}

class PlayerSeek extends PlayerEvent {
  final Duration position;

  const PlayerSeek(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayerPositionChanged extends PlayerEvent {
  final Duration position;

  const PlayerPositionChanged(this.position);

  @override
  List<Object?> get props => [position];
}

class PlayerDurationChanged extends PlayerEvent {
  final Duration duration;

  const PlayerDurationChanged(this.duration);

  @override
  List<Object?> get props => [duration];
}

class PlayerCompleted extends PlayerEvent {}

class PlayerToggleFavorite extends PlayerEvent {}

class PlayerHideMiniPlayer extends PlayerEvent {}

class PlayerShowMiniPlayer extends PlayerEvent {}
