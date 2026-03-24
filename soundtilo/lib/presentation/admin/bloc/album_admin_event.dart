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
