import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/playlist_track_entity.dart';

class PlaylistDetailEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final bool isPublic;
  final List<PlaylistTrackEntity> tracks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistDetailEntity({
    required this.id,
    required this.name,
    this.description,
    required this.isPublic,
    required this.tracks,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    isPublic,
    tracks,
    updatedAt,
  ];
}
