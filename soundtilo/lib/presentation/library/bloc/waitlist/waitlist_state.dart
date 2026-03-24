import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';

abstract class WaitlistState extends Equatable {
  const WaitlistState();
  @override List<Object?> get props => [];
}

class WaitlistInitial extends WaitlistState {}
class WaitlistLoading extends WaitlistState {}

class WaitlistLoaded extends WaitlistState {
  final List<TrackEntity> tracks;
  final int fadedCount; // GHI NHỚ SỐ LƯỢNG BÀI MỜ (0 ĐẾN 3)

  const WaitlistLoaded({required this.tracks, this.fadedCount = 0});

  WaitlistLoaded copyWith({List<TrackEntity>? tracks, int? fadedCount}) {
    return WaitlistLoaded(
      tracks: tracks ?? this.tracks,
      fadedCount: fadedCount ?? this.fadedCount,
    );
  }

  @override List<Object?> get props => [tracks, fadedCount];
}

class WaitlistError extends WaitlistState {
  final String message;
  const WaitlistError(this.message);
  @override List<Object?> get props => [message];
}