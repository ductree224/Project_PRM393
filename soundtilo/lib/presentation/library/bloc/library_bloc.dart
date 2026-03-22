import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/debug/perf_trace.dart';
import 'package:soundtilo/domain/entities/playlist_entity.dart';
import 'package:soundtilo/domain/usecases/playlist_usecases.dart';
import 'package:soundtilo/domain/usecases/favorite_usecases.dart';
import 'package:soundtilo/presentation/library/bloc/library_event.dart';
import 'package:soundtilo/presentation/library/bloc/library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  static const Duration _loadTimeout = Duration(seconds: 3);
  final GetPlaylistsUseCase _getPlaylistsUseCase;
  final CreatePlaylistUseCase _createPlaylistUseCase;
  final UpdatePlaylistUseCase _updatePlaylistUseCase;
  final DeletePlaylistUseCase _deletePlaylistUseCase;
  final AddTrackToPlaylistUseCase _addTrackToPlaylistUseCase;
  final RemoveTrackFromPlaylistUseCase _removeTrackFromPlaylistUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final GetFavoritesUseCase _getFavoritesUseCase;

  LibraryBloc({
    required GetPlaylistsUseCase getPlaylistsUseCase,
    required CreatePlaylistUseCase createPlaylistUseCase,
    required UpdatePlaylistUseCase updatePlaylistUseCase,
    required DeletePlaylistUseCase deletePlaylistUseCase,
    required AddTrackToPlaylistUseCase addTrackToPlaylistUseCase,
    required RemoveTrackFromPlaylistUseCase removeTrackFromPlaylistUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
    required GetFavoritesUseCase getFavoritesUseCase,
  })  : _getPlaylistsUseCase = getPlaylistsUseCase,
        _createPlaylistUseCase = createPlaylistUseCase,
        _updatePlaylistUseCase = updatePlaylistUseCase,
        _deletePlaylistUseCase = deletePlaylistUseCase,
        _addTrackToPlaylistUseCase = addTrackToPlaylistUseCase,
        _removeTrackFromPlaylistUseCase = removeTrackFromPlaylistUseCase,
        _toggleFavoriteUseCase = toggleFavoriteUseCase,
        _getFavoritesUseCase = getFavoritesUseCase,
        super(LibraryInitial()) {
    on<LibraryLoad>(_onLoad, transformer: droppable());
    on<LibraryCreatePlaylist>(_onCreatePlaylist, transformer: droppable());
    on<LibraryDeletePlaylist>(_onDeletePlaylist, transformer: droppable());
    on<LibraryUpdatePlaylist>(_onUpdatePlaylist, transformer: droppable());
    on<LibraryAddTrackToPlaylist>(_onAddTrackToPlaylist, transformer: droppable());
    on<LibraryRemoveTrackFromPlaylist>(_onRemoveTrackFromPlaylist, transformer: droppable());
    on<LibraryToggleFavorite>(_onToggleFavorite, transformer: droppable());
    on<LibraryFavoriteSync>(_onFavoriteSync);
  }

  Future<void> _onLoad(LibraryLoad event, Emitter<LibraryState> emit) async {
    if (state is LibraryLoaded || state is LibraryRefreshing || state is LibraryLoading) {
      PerfTrace.log(
        'library.load.skip',
        'skip duplicate load while library already has content/loading',
      );
      return;
    }

    final stopwatch = Stopwatch()..start();
    final previousState = state;
    final previousLoaded = _extractLoadedState(previousState);
    if (previousLoaded == null) {
      emit(LibraryLoading());
    } else {
      emit(LibraryRefreshing(
        playlists: previousLoaded.playlists,
        favoriteTrackIds: previousLoaded.favoriteTrackIds,
      ));
    }

    final playlistsResult = await _getPlaylistsUseCase().timeout(
      _loadTimeout,
      onTimeout: () {
        PerfTrace.log('library.load.timeout', 'playlists fetch timed out');
        return Left<String, List<PlaylistEntity>>('timeout');
      },
    );

    final favoritesResult = await _getFavoritesUseCase().timeout(
      _loadTimeout,
      onTimeout: () {
        PerfTrace.log('library.load.timeout', 'favorites fetch timed out');
        return Left<String, List<String>>('timeout');
      },
    );

    final playlists = playlistsResult.fold(
      (_) => previousLoaded?.playlists ?? <PlaylistEntity>[],
      (v) => v,
    );
    final favorites = favoritesResult.fold(
      (_) => previousLoaded?.favoriteTrackIds ?? <String>[],
      (v) => v,
    );

    emit(LibraryLoaded(
      playlists: List.from(playlists),
      favoriteTrackIds: List.from(favorites),
    ));

    stopwatch.stop();
    PerfTrace.slow(
      'library.load',
      stopwatch,
      thresholdMs: 180,
      values: <String, Object?>{
        'playlistCount': playlists.length,
        'favoriteCount': favorites.length,
      },
    );
  }

  Future<void> _onCreatePlaylist(
      LibraryCreatePlaylist event, Emitter<LibraryState> emit) async {
    final stopwatch = Stopwatch()..start();
    final result = await _createPlaylistUseCase(
      name: event.name,
      description: event.description,
    );

    result.fold(
      (error) => emit(LibraryError(error)),
      (createdPlaylist) {
        final loadedState = _extractLoadedState(state);
        if (loadedState == null) {
          add(LibraryLoad());
          return;
        }

        emit(LibraryLoaded(
          playlists: [createdPlaylist, ...loadedState.playlists],
          favoriteTrackIds: loadedState.favoriteTrackIds,
        ));
      },
    );

    stopwatch.stop();
    PerfTrace.slow(
      'library.createPlaylist',
      stopwatch,
      thresholdMs: 180,
      values: <String, Object?>{'nameLength': event.name.length},
    );
  }

  Future<void> _onDeletePlaylist(
      LibraryDeletePlaylist event, Emitter<LibraryState> emit) async {
    final stopwatch = Stopwatch()..start();
    final loadedState = _extractLoadedState(state);
    if (loadedState == null) {
      return;
    }

    final result = await _deletePlaylistUseCase(event.playlistId);
    result.fold(
      (error) => emit(LibraryError(error)),
      (_) {
        emit(LibraryLoaded(
          playlists: loadedState.playlists
              .where((playlist) => playlist.id != event.playlistId)
              .toList(growable: false),
          favoriteTrackIds: loadedState.favoriteTrackIds,
        ));
      },
    );

    stopwatch.stop();
    PerfTrace.slow(
      'library.deletePlaylist',
      stopwatch,
      thresholdMs: 80,
      values: <String, Object?>{'playlistId': event.playlistId},
    );
  }

  Future<void> _onUpdatePlaylist(
    LibraryUpdatePlaylist event,
    Emitter<LibraryState> emit,
  ) async {
    final stopwatch = Stopwatch()..start();
    final loadedState = _extractLoadedState(state);
    if (loadedState == null) {
      return;
    }

    final result = await _updatePlaylistUseCase(
      event.playlistId,
      name: event.name,
      description: event.description,
      isPublic: event.isPublic,
    );

    result.fold(
      (error) => emit(LibraryError(error)),
      (updatedPlaylist) {
        final playlists = loadedState.playlists
            .map(
              (playlist) => playlist.id == event.playlistId
                  ? updatedPlaylist
                  : playlist,
            )
            .toList(growable: false);
        emit(LibraryLoaded(
          playlists: playlists,
          favoriteTrackIds: loadedState.favoriteTrackIds,
        ));
      },
    );

    stopwatch.stop();
    PerfTrace.slow(
      'library.updatePlaylist',
      stopwatch,
      thresholdMs: 120,
      values: <String, Object?>{
        'playlistId': event.playlistId,
      },
    );
  }

  Future<void> _onAddTrackToPlaylist(
    LibraryAddTrackToPlaylist event,
    Emitter<LibraryState> emit,
  ) async {
    final stopwatch = Stopwatch()..start();
    final loadedState = _extractLoadedState(state);
    if (loadedState == null) {
      return;
    }

    final result = await _addTrackToPlaylistUseCase(
      event.playlistId,
      event.trackExternalId,
    );

    result.fold(
      (error) => emit(LibraryError(error)),
      (_) {
        final playlists = loadedState.playlists
            .map(
              (playlist) => playlist.id == event.playlistId
                  ? PlaylistEntity(
                      id: playlist.id,
                      name: playlist.name,
                      description: playlist.description,
                      isPublic: playlist.isPublic,
                      trackCount: playlist.trackCount + 1,
                      createdAt: playlist.createdAt,
                      updatedAt: playlist.updatedAt,
                    )
                  : playlist,
            )
            .toList(growable: false);

        emit(LibraryLoaded(
          playlists: playlists,
          favoriteTrackIds: loadedState.favoriteTrackIds,
        ));
      },
    );

    stopwatch.stop();
    PerfTrace.slow(
      'library.addTrackToPlaylist',
      stopwatch,
      thresholdMs: 120,
      values: <String, Object?>{
        'playlistId': event.playlistId,
        'trackId': event.trackExternalId,
      },
    );
  }

  Future<void> _onRemoveTrackFromPlaylist(
    LibraryRemoveTrackFromPlaylist event,
    Emitter<LibraryState> emit,
  ) async {
    final stopwatch = Stopwatch()..start();
    final loadedState = _extractLoadedState(state);
    if (loadedState == null) {
      return;
    }

    final result = await _removeTrackFromPlaylistUseCase(
      event.playlistId,
      event.trackExternalId,
    );

    result.fold(
      (error) => emit(LibraryError(error)),
      (_) {
        final playlists = loadedState.playlists
            .map(
              (playlist) => playlist.id == event.playlistId
                  ? PlaylistEntity(
                      id: playlist.id,
                      name: playlist.name,
                      description: playlist.description,
                      isPublic: playlist.isPublic,
                      trackCount: playlist.trackCount > 0
                          ? playlist.trackCount - 1
                          : 0,
                      createdAt: playlist.createdAt,
                      updatedAt: playlist.updatedAt,
                    )
                  : playlist,
            )
            .toList(growable: false);

        emit(LibraryLoaded(
          playlists: playlists,
          favoriteTrackIds: loadedState.favoriteTrackIds,
        ));
      },
    );

    stopwatch.stop();
    PerfTrace.slow(
      'library.removeTrackFromPlaylist',
      stopwatch,
      thresholdMs: 120,
      values: <String, Object?>{
        'playlistId': event.playlistId,
        'trackId': event.trackExternalId,
      },
    );
  }

  Future<void> _onToggleFavorite(
    LibraryToggleFavorite event,
    Emitter<LibraryState> emit,
  ) async {
    final stopwatch = Stopwatch()..start();
    final loadedState = _extractLoadedState(state);
    if (loadedState == null) {
      return;
    }

    final result = await _toggleFavoriteUseCase(event.trackExternalId);
    result.fold(
      (error) => emit(LibraryError(error)),
      (isFavorite) {
        final favoriteTrackIds = List<String>.from(loadedState.favoriteTrackIds);
        if (isFavorite) {
          if (!favoriteTrackIds.contains(event.trackExternalId)) {
            favoriteTrackIds.add(event.trackExternalId);
          }
        } else {
          favoriteTrackIds.remove(event.trackExternalId);
        }

        emit(LibraryLoaded(
          playlists: loadedState.playlists,
          favoriteTrackIds: favoriteTrackIds,
        ));
      },
    );

    stopwatch.stop();
    PerfTrace.slow(
      'library.toggleFavorite',
      stopwatch,
      thresholdMs: 100,
      values: <String, Object?>{'trackId': event.trackExternalId},
    );
  }

  void _onFavoriteSync(
    LibraryFavoriteSync event,
    Emitter<LibraryState> emit,
  ) {
    final loadedState = _extractLoadedState(state);
    if (loadedState == null) return;

    final ids = List<String>.from(loadedState.favoriteTrackIds);
    if (event.isFavorite) {
      if (!ids.contains(event.trackExternalId)) {
        ids.add(event.trackExternalId);
      }
    } else {
      ids.remove(event.trackExternalId);
    }

    emit(LibraryLoaded(
      playlists: loadedState.playlists,
      favoriteTrackIds: ids,
    ));
  }

  LibraryLoaded? _extractLoadedState(LibraryState sourceState) {
    if (sourceState is LibraryLoaded) {
      return sourceState;
    }
    if (sourceState is LibraryRefreshing) {
      return LibraryLoaded(
        playlists: sourceState.playlists,
        favoriteTrackIds: sourceState.favoriteTrackIds,
      );
    }
    return null;
  }
}
