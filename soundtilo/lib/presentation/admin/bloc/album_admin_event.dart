import 'package:equatable/equatable.dart';

abstract class AlbumAdminEvent extends Equatable {
  const AlbumAdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlbums extends AlbumAdminEvent {
  final String? tag;
  final String? artistId;
  const LoadAlbums({this.tag, this.artistId});

  @override
  List<Object?> get props => [tag, artistId];
}

class CreateAlbum extends AlbumAdminEvent {
  final Map<String, dynamic> data;
  const CreateAlbum(this.data);

  @override
  List<Object?> get props => [data];
}

class UpdateAlbum extends AlbumAdminEvent {
  final String id;
  final Map<String, dynamic> data;
  const UpdateAlbum(this.id, this.data);

  @override
  List<Object?> get props => [id, data];
}

class DeleteAlbum extends AlbumAdminEvent {
  final String id;
  const DeleteAlbum(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadAlbumDetail extends AlbumAdminEvent {
  final String id;
  const LoadAlbumDetail(this.id);

  @override
  List<Object?> get props => [id];
}

class AddTrackToAlbum extends AlbumAdminEvent {
  final String albumId;
  final String trackExternalId;
  final int position;
  const AddTrackToAlbum({required this.albumId, required this.trackExternalId, required this.position});

  @override
  List<Object?> get props => [albumId, trackExternalId, position];
}

class RemoveTrackFromAlbum extends AlbumAdminEvent {
  final String albumId;
  final String trackExternalId;
  const RemoveTrackFromAlbum({required this.albumId, required this.trackExternalId});

  @override
  List<Object?> get props => [albumId, trackExternalId];
}
