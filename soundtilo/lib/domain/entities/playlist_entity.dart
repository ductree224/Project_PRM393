import 'package:equatable/equatable.dart';

class PlaylistEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final bool isPublic;
  final int trackCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlaylistEntity({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    this.isPublic = false,
    this.trackCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, trackCount];
}
