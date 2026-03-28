import 'package:equatable/equatable.dart';

abstract class TrackAdminEvent extends Equatable {
  const TrackAdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadTracks extends TrackAdminEvent {
  final String? status;
  final String? query;
  final int limit;
  final int offset;

  const LoadTracks({
    this.status,
    this.query,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [status, query, limit, offset];
}

class UpdateTrackStatus extends TrackAdminEvent {
  final List<String> externalIds;
  final String status;

  const UpdateTrackStatus({
    required this.externalIds,
    required this.status,
  });

  @override
  List<Object?> get props => [externalIds, status];
}
class AddTracksToAlbum extends TrackAdminEvent {
  final String albumId;
  final List<String> trackIds;

  const AddTracksToAlbum({
    required this.albumId,
    required this.trackIds,
  });

  @override
  List<Object?> get props => [albumId, trackIds];
}
