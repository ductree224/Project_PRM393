import 'package:equatable/equatable.dart';
import '../../../../data/models/album_model.dart';

abstract class AlbumAdminState extends Equatable {
  const AlbumAdminState();
  
  @override
  List<Object?> get props => [];
}

class AlbumAdminInitial extends AlbumAdminState {}

class AlbumAdminLoading extends AlbumAdminState {}

class AlbumAdminLoaded extends AlbumAdminState {
  final List<AlbumModel> albums;
  const AlbumAdminLoaded(this.albums);

  @override
  List<Object?> get props => [albums];
}

class AlbumAdminError extends AlbumAdminState {
  final String message;
  const AlbumAdminError(this.message);

  @override
  List<Object?> get props => [message];
}

class AlbumAdminOperationSuccess extends AlbumAdminState {
  final String message;
  const AlbumAdminOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AlbumAdminDetailLoaded extends AlbumAdminState {
  final AlbumModel album;
  const AlbumAdminDetailLoaded(this.album);

  @override
  List<Object?> get props => [album];
}
