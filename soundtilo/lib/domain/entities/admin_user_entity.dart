import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String role;
  final bool isBanned;
  final DateTime? bannedAt;
  final String? bannedReason;
  final DateTime createdAt;
  final String subscriptionTier;
  final DateTime? premiumExpiresAt;

  const AdminUserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarUrl,
    required this.role,
    required this.isBanned,
    this.bannedAt,
    this.bannedReason,
    required this.createdAt,
    this.subscriptionTier = 'free',
    this.premiumExpiresAt,
  });

  bool get isPremium => subscriptionTier == 'premium';

  String get displayLabel {
    final value = (displayName ?? '').trim();
    return value.isEmpty ? username : value;
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    displayName,
    avatarUrl,
    role,
    isBanned,
    bannedAt,
    bannedReason,
    createdAt,
    subscriptionTier,
    premiumExpiresAt,
  ];
}

class AdminUserListEntity extends Equatable {
  final List<AdminUserEntity> users;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const AdminUserListEntity({
    required this.users,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [users, total, page, pageSize, totalPages];
}

class AdminUserHistoryItemEntity extends Equatable {
  final String id;
  final String trackExternalId;
  final DateTime listenedAt;
  final int durationListened;
  final bool completed;

  const AdminUserHistoryItemEntity({
    required this.id,
    required this.trackExternalId,
    required this.listenedAt,
    required this.durationListened,
    required this.completed,
  });

  @override
  List<Object?> get props => [
    id,
    trackExternalId,
    listenedAt,
    durationListened,
    completed,
  ];
}

class AdminUserHistoryListEntity extends Equatable {
  final List<AdminUserHistoryItemEntity> history;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const AdminUserHistoryListEntity({
    required this.history,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [history, total, page, pageSize, totalPages];
}

class AdminUserFavoriteItemEntity extends Equatable {
  final String trackExternalId;
  final DateTime createdAt;

  const AdminUserFavoriteItemEntity({
    required this.trackExternalId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [trackExternalId, createdAt];
}

class AdminUserFavoriteListEntity extends Equatable {
  final List<AdminUserFavoriteItemEntity> favorites;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const AdminUserFavoriteListEntity({
    required this.favorites,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [favorites, total, page, pageSize, totalPages];
}

class AdminUserPlaylistItemEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final bool isPublic;
  final int trackCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdminUserPlaylistItemEntity({
    required this.id,
    required this.name,
    this.description,
    this.coverImageUrl,
    required this.isPublic,
    required this.trackCount,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    coverImageUrl,
    isPublic,
    trackCount,
    createdAt,
    updatedAt,
  ];
}

class AdminUserPlaylistListEntity extends Equatable {
  final List<AdminUserPlaylistItemEntity> playlists;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const AdminUserPlaylistListEntity({
    required this.playlists,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  @override
  List<Object?> get props => [playlists, total, page, pageSize, totalPages];
}
