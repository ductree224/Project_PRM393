import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<TrackEntity> trendingTracks;

  const HomeLoaded({required this.trendingTracks});

  @override
  List<Object?> get props => [trendingTracks];
}

class HomeRefreshing extends HomeState {
  final List<TrackEntity> trendingTracks;

  const HomeRefreshing({required this.trendingTracks});

  @override
  List<Object?> get props => [trendingTracks];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
