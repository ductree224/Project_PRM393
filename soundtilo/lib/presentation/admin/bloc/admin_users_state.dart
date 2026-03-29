import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';

enum AdminUsersStatus { initial, loading, loaded, error }

class AdminUsersState extends Equatable {
  final AdminUsersStatus status;
  final List<AdminUserEntity> users;
  final int page;
  final int pageSize;
  final int total;
  final int totalPages;
  final String search;
  final String? role;
  final bool? isBanned;
  final String? subscriptionTier;
  final bool isLoadingMore;
  final bool isSubmitting;
  final String? errorMessage;
  final String? actionMessage;

  const AdminUsersState({
    this.status = AdminUsersStatus.initial,
    this.users = const <AdminUserEntity>[],
    this.page = 1,
    this.pageSize = 20,
    this.total = 0,
    this.totalPages = 0,
    this.search = '',
    this.role,
    this.isBanned,
    this.subscriptionTier,
    this.isLoadingMore = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.actionMessage,
  });

  bool get hasMore => page < totalPages;

  AdminUsersState copyWith({
    AdminUsersStatus? status,
    List<AdminUserEntity>? users,
    int? page,
    int? pageSize,
    int? total,
    int? totalPages,
    String? search,
    Object? role = _sentinel,
    Object? isBanned = _sentinel,
    Object? subscriptionTier = _sentinel,
    bool? isLoadingMore,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
    Object? actionMessage = _sentinel,
  }) {
    return AdminUsersState(
      status: status ?? this.status,
      users: users ?? this.users,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      search: search ?? this.search,
      role: role == _sentinel ? this.role : role as String?,
      isBanned: isBanned == _sentinel ? this.isBanned : isBanned as bool?,
      subscriptionTier: subscriptionTier == _sentinel
          ? this.subscriptionTier
          : subscriptionTier as String?,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      actionMessage: actionMessage == _sentinel
          ? this.actionMessage
          : actionMessage as String?,
    );
  }

  @override
  List<Object?> get props => [
    status,
    users,
    page,
    pageSize,
    total,
    totalPages,
    search,
    role,
    isBanned,
    subscriptionTier,
    isLoadingMore,
    isSubmitting,
    errorMessage,
    actionMessage,
  ];
}

const Object _sentinel = Object();
