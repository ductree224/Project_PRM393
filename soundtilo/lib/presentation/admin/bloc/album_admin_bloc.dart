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
    on<LoadAlbumDetail>(_onLoadAlbumDetail);
    on<AddTrackToAlbum>(_onAddTrack);
    on<RemoveTrackFromAlbum>(_onRemoveTrack);
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

  Future<void> _onLoadAlbumDetail(LoadAlbumDetail event, Emitter<AlbumAdminState> emit) async {
    emit(AlbumAdminLoading());
    final result = await repository.getAlbumById(event.id, includeTracks: true);
    result.fold(
      (error) => emit(AlbumAdminError(error)),
      (album) => emit(AlbumAdminDetailLoaded(album)),
    );
  }

  Future<void> _onAddTrack(AddTrackToAlbum event, Emitter<AlbumAdminState> emit) async {
    // Note: We don't emit loading here because the UI might want to stay in its current state
    final result = await repository.addTrack(event.albumId, event.trackExternalId, event.position);
    result.fold(
      (error) => emit(AlbumAdminError(error)),
      (_) {
        emit(const AlbumAdminOperationSuccess('Track added to album'));
        add(LoadAlbumDetail(event.albumId));
      },
    );
  }

  Future<void> _onRemoveTrack(RemoveTrackFromAlbum event, Emitter<AlbumAdminState> emit) async {
    final result = await repository.removeTrack(event.albumId, event.trackExternalId);
    result.fold(
      (error) => emit(AlbumAdminError(error)),
      (_) {
        emit(const AlbumAdminOperationSuccess('Track removed from album'));
        add(LoadAlbumDetail(event.albumId));
      },
    );
  }
}
