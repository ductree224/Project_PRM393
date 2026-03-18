import 'package:equatable/equatable.dart';

class PlaylistTrackEntity extends Equatable {
  final String trackExternalId;
  final int position;
  final DateTime addedAt;

  const PlaylistTrackEntity({
    required this.trackExternalId,
    required this.position,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [trackExternalId, position, addedAt];
}
