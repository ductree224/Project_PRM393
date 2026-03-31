import 'package:equatable/equatable.dart';

abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();

  @override
  List<Object?> get props => [];
}

class AdminUsersStarted extends AdminUsersEvent {
  const AdminUsersStarted();
}

class AdminUsersSearchChanged extends AdminUsersEvent {
  final String query;

  const AdminUsersSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class AdminUsersRoleFilterChanged extends AdminUsersEvent {
  final String? role;

  const AdminUsersRoleFilterChanged(this.role);

  @override
  List<Object?> get props => [role];
}

class AdminUsersBanFilterChanged extends AdminUsersEvent {
  final bool? isBanned;

  const AdminUsersBanFilterChanged(this.isBanned);

  @override
  List<Object?> get props => [isBanned];
}

class AdminUsersLoadMore extends AdminUsersEvent {
  const AdminUsersLoadMore();
}

class AdminUsersRefresh extends AdminUsersEvent {
  const AdminUsersRefresh();
}

class AdminUsersBanToggleRequested extends AdminUsersEvent {
  final String userId;
  final bool isCurrentlyBanned;
  final String? reason;

  const AdminUsersBanToggleRequested({
    required this.userId,
    required this.isCurrentlyBanned,
    this.reason,
  });

  @override
  List<Object?> get props => [userId, isCurrentlyBanned, reason];
}

class AdminUsersRoleChangeRequested extends AdminUsersEvent {
  final String userId;
  final String newRole;

  const AdminUsersRoleChangeRequested({
    required this.userId,
    required this.newRole,
  });

  @override
  List<Object?> get props => [userId, newRole];
}

class AdminUsersDeleteRequested extends AdminUsersEvent {
  final String userId;

  const AdminUsersDeleteRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AdminUsersSubscriptionTierFilterChanged extends AdminUsersEvent {
  final String? subscriptionTier;

  const AdminUsersSubscriptionTierFilterChanged(this.subscriptionTier);

  @override
  List<Object?> get props => [subscriptionTier];
}

class AdminUsersGrantPremiumRequested extends AdminUsersEvent {
  final String userId;
  final DateTime? expiresAt;

  const AdminUsersGrantPremiumRequested({
    required this.userId,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [userId, expiresAt];
}

class AdminUsersRevokePremiumRequested extends AdminUsersEvent {
  final String userId;

  const AdminUsersRevokePremiumRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}
