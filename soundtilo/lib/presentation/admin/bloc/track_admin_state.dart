import 'package:equatable/equatable.dart';
import '../../../../data/models/track_admin_model.dart';
import '../../../../data/models/track_model.dart';

abstract class TrackAdminState extends Equatable {
  const TrackAdminState();

  @override
  List<Object?> get props => [];
}

class TrackAdminInitial extends TrackAdminState {}

class TrackAdminLoading extends TrackAdminState {}

class TrackAdminLoaded extends TrackAdminState {
  final List<TrackAdminModel> tracks;
  final String? currentStatus; // Filter
  final String? currentQuery; // Filter

  const TrackAdminLoaded({
    required this.tracks,
    this.currentStatus,
    this.currentQuery,
  });

  @override
  List<Object?> get props => [tracks, currentStatus, currentQuery];
}

class TrackAdminError extends TrackAdminState {
  final String message;

  const TrackAdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class TrackAdminOperationInProgress extends TrackAdminState {
  final List<TrackAdminModel> tracks;
  final String? currentStatus;
  final String? currentQuery;

  const TrackAdminOperationInProgress({
    required this.tracks,
    this.currentStatus,
    this.currentQuery,
  });

  @override
  List<Object?> get props => [tracks, currentStatus, currentQuery];
}

class TrackAdminOperationSuccess extends TrackAdminState {
  final String message;

  const TrackAdminOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TrackAdminDiscoveryLoaded extends TrackAdminState {
  final List<TrackModel> results;

  const TrackAdminDiscoveryLoaded(this.results);

  @override
  List<Object?> get props => [results];
}
