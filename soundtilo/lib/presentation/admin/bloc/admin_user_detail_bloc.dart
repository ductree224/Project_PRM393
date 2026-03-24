import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';
import 'package:soundtilo/domain/usecases/admin_user_usecases.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_user_detail_event.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_user_detail_state.dart';

class AdminUserDetailBloc
    extends Bloc<AdminUserDetailEvent, AdminUserDetailState> {
  final GetAdminUserHistoryUseCase _getAdminUserHistoryUseCase;
  final GetAdminUserFavoritesUseCase _getAdminUserFavoritesUseCase;
  final GetAdminUserPlaylistsUseCase _getAdminUserPlaylistsUseCase;

  AdminUserDetailBloc({
    required GetAdminUserHistoryUseCase getAdminUserHistoryUseCase,
    required GetAdminUserFavoritesUseCase getAdminUserFavoritesUseCase,
    required GetAdminUserPlaylistsUseCase getAdminUserPlaylistsUseCase,
  }) : _getAdminUserHistoryUseCase = getAdminUserHistoryUseCase,
       _getAdminUserFavoritesUseCase = getAdminUserFavoritesUseCase,
       _getAdminUserPlaylistsUseCase = getAdminUserPlaylistsUseCase,
       super(const AdminUserDetailState()) {
    on<AdminUserDetailStarted>(_onStarted, transformer: restartable());
    on<AdminUserDetailRefresh>(_onRefresh, transformer: droppable());
    on<AdminUserDetailLoadMore>(_onLoadMore, transformer: droppable());
  }

  Future<void> _onStarted(
    AdminUserDetailStarted event,
    Emitter<AdminUserDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AdminUserDetailStatus.loading,
        userId: event.userId,
        section: event.section,
        page: 1,
        total: 0,
        totalPages: 0,
        history: const <AdminUserHistoryItemEntity>[],
        favorites: const <AdminUserFavoriteItemEntity>[],
        playlists: const <AdminUserPlaylistItemEntity>[],
        errorMessage: null,
      ),
    );

    await _loadPage(emit, page: 1, append: false);
  }

  Future<void> _onRefresh(
    AdminUserDetailRefresh event,
    Emitter<AdminUserDetailState> emit,
  ) async {
    if (state.userId.isEmpty) {
      return;
    }
    emit(
      state.copyWith(
        status: AdminUserDetailStatus.loading,
        page: 1,
        errorMessage: null,
      ),
    );
    await _loadPage(emit, page: 1, append: false);
  }

  Future<void> _onLoadMore(
    AdminUserDetailLoadMore event,
    Emitter<AdminUserDetailState> emit,
  ) async {
    if (state.userId.isEmpty || state.isLoadingMore || !state.hasMore) {
      return;
    }

    final nextPage = state.page + 1;
    emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    await _loadPage(emit, page: nextPage, append: true);
  }

  Future<void> _loadPage(
    Emitter<AdminUserDetailState> emit, {
    required int page,
    required bool append,
  }) async {
    final userId = state.userId;

    switch (state.section) {
      case AdminUserDetailSection.history:
        final result = await _getAdminUserHistoryUseCase(
          userId,
          page: page,
          pageSize: state.pageSize,
        );
        result.fold(
          (error) => emit(
            state.copyWith(
              status: AdminUserDetailStatus.error,
              isLoadingMore: false,
              errorMessage: error,
            ),
          ),
          (data) => emit(
            state.copyWith(
              status: AdminUserDetailStatus.loaded,
              history: append
                  ? [...state.history, ...data.history]
                  : data.history,
              page: data.page,
              pageSize: data.pageSize,
              total: data.total,
              totalPages: data.totalPages,
              isLoadingMore: false,
              errorMessage: null,
            ),
          ),
        );
        break;
      case AdminUserDetailSection.favorites:
        final result = await _getAdminUserFavoritesUseCase(
          userId,
          page: page,
          pageSize: state.pageSize,
        );
        result.fold(
          (error) => emit(
            state.copyWith(
              status: AdminUserDetailStatus.error,
              isLoadingMore: false,
              errorMessage: error,
            ),
          ),
          (data) => emit(
            state.copyWith(
              status: AdminUserDetailStatus.loaded,
              favorites: append
                  ? [...state.favorites, ...data.favorites]
                  : data.favorites,
              page: data.page,
              pageSize: data.pageSize,
              total: data.total,
              totalPages: data.totalPages,
              isLoadingMore: false,
              errorMessage: null,
            ),
          ),
        );
        break;
      case AdminUserDetailSection.playlists:
        final result = await _getAdminUserPlaylistsUseCase(
          userId,
          page: page,
          pageSize: state.pageSize,
        );
        result.fold(
          (error) => emit(
            state.copyWith(
              status: AdminUserDetailStatus.error,
              isLoadingMore: false,
              errorMessage: error,
            ),
          ),
          (data) => emit(
            state.copyWith(
              status: AdminUserDetailStatus.loaded,
              playlists: append
                  ? [...state.playlists, ...data.playlists]
                  : data.playlists,
              page: data.page,
              pageSize: data.pageSize,
              total: data.total,
              totalPages: data.totalPages,
              isLoadingMore: false,
              errorMessage: null,
            ),
          ),
        );
        break;
    }
  }
}
