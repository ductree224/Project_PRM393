import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';

enum AdminUserDetailSection { history, favorites, playlists }

enum AdminUserDetailStatus { initial, loading, loaded, error }

class AdminUserDetailState extends Equatable {
  final AdminUserDetailStatus status;
  final String userId;
  final AdminUserDetailSection section;
  final List<AdminUserHistoryItemEntity> history;
  final List<AdminUserFavoriteItemEntity> favorites;
  final List<AdminUserPlaylistItemEntity> playlists;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final bool isLoadingMore;
  final String? errorMessage;

  const AdminUserDetailState({
    this.status = AdminUserDetailStatus.initial,
    this.userId = '',
    this.section = AdminUserDetailSection.history,
    this.history = const <AdminUserHistoryItemEntity>[],
    this.favorites = const <AdminUserFavoriteItemEntity>[],
    this.playlists = const <AdminUserPlaylistItemEntity>[],
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.totalPages = 0,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  bool get hasMore => page < totalPages;

  AdminUserDetailState copyWith({
    AdminUserDetailStatus? status,
    String? userId,
    AdminUserDetailSection? section,
    List<AdminUserHistoryItemEntity>? history,
    List<AdminUserFavoriteItemEntity>? favorites,
    List<AdminUserPlaylistItemEntity>? playlists,
    int? page,
    int? pageSize,
    int? total,
    int? totalPages,
    bool? isLoadingMore,
    Object? errorMessage = _sentinel,
  }) {
    return AdminUserDetailState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      section: section ?? this.section,
      history: history ?? this.history,
      favorites: favorites ?? this.favorites,
      playlists: playlists ?? this.playlists,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    userId,
    section,
    history,
    favorites,
    playlists,
    page,
    pageSize,
    total,
    totalPages,
    isLoadingMore,
    errorMessage,
  ];
}

const Object _sentinel = Object();
