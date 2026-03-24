import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/album_repository.dart';
import 'album_admin_event.dart';
import 'album_admin_state.dart';

class AlbumAdminBloc extends Bloc<AlbumAdminEvent, AlbumAdminState> {
  final AlbumRepository repository;

  AlbumAdminBloc({required this.repository}) : super(AlbumAdminInitial()) {
    on<LoadAlbums>(_onLoadAlbums);
    on<CreateAlbum>(_onCreateAlbum);
    on<UpdateAlbum>(_onUpdateAlbum);
    on<DeleteAlbum>(_onDeleteAlbum);
  }

  Future<void> _onLoadAlbums(LoadAlbums event, Emitter<AlbumAdminState> emit) async {
    emit(AlbumAdminLoading());
    final result = await repository.getAlbums(tag: event.tag, artistId: event.artistId);
    result.fold(
      (error) => emit(AlbumAdminError(error)),
      (albums) => emit(AlbumAdminLoaded(albums)),
    );
  }

  Future<void> _onCreateAlbum(CreateAlbum event, Emitter<AlbumAdminState> emit) async {
    emit(AlbumAdminLoading());
    final result = await repository.createAlbum(event.data);
    result.fold(
      (error) => emit(AlbumAdminError(error)),
      (_) {
        // Re-load albums after successful creation
        emit(const AlbumAdminOperationSuccess('Album created successfully'));
        add(const LoadAlbums());
      },
    );
  }

  Future<void> _onUpdateAlbum(UpdateAlbum event, Emitter<AlbumAdminState> emit) async {
    emit(AlbumAdminLoading());
    final result = await repository.updateAlbum(event.id, event.data);
    result.fold(
      (error) => emit(AlbumAdminError(error)),
      (_) {
        emit(const AlbumAdminOperationSuccess('Album updated successfully'));
        add(const LoadAlbums());
      },
    );
  }

  Future<void> _onDeleteAlbum(DeleteAlbum event, Emitter<AlbumAdminState> emit) async {
    emit(AlbumAdminLoading());
    final result = await repository.deleteAlbum(event.id);
    result.fold(
      (error) => emit(AlbumAdminError(error)),
      (_) {
        emit(const AlbumAdminOperationSuccess('Album deleted successfully'));
        add(const LoadAlbums());
      },
    );
  }
}
