import 'package:soundtilo/domain/entities/admin_user_entity.dart';

class AdminUserModel extends AdminUserEntity {
  const AdminUserModel({
    required super.id,
    required super.username,
    required super.email,
    super.displayName,
    super.avatarUrl,
    required super.role,
    required super.isBanned,
    super.bannedAt,
    super.bannedReason,
    required super.createdAt,
    super.subscriptionTier = 'free',
    super.premiumExpiresAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: (json['id'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      displayName: json['displayName']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      role: (json['role'] ?? 'user').toString(),
      isBanned: json['isBanned'] == true,
      bannedAt: _tryParseDateTime(json['bannedAt']),
      bannedReason: json['bannedReason']?.toString(),
      createdAt: _tryParseDateTime(json['createdAt']) ?? DateTime.now(),
      subscriptionTier: (json['subscriptionTier'] ?? 'free').toString(),
      premiumExpiresAt: _tryParseDateTime(json['premiumExpiresAt']),
    );
  }

  static DateTime? _tryParseDateTime(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw)?.toLocal();
  }
}

class AdminUserHistoryItemModel extends AdminUserHistoryItemEntity {
  const AdminUserHistoryItemModel({
    required super.id,
    required super.trackExternalId,
    required super.listenedAt,
    required super.durationListened,
    required super.completed,
  });

  factory AdminUserHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return AdminUserHistoryItemModel(
      id: (json['id'] ?? '').toString(),
      trackExternalId: (json['trackExternalId'] ?? '').toString(),
      listenedAt:
          AdminUserModel._tryParseDateTime(json['listenedAt']) ??
          DateTime.now(),
      durationListened: (json['durationListened'] as num?)?.toInt() ?? 0,
      completed: json['completed'] == true,
    );
  }
}

class AdminUserFavoriteItemModel extends AdminUserFavoriteItemEntity {
  const AdminUserFavoriteItemModel({
    required super.trackExternalId,
    required super.createdAt,
  });

  factory AdminUserFavoriteItemModel.fromJson(Map<String, dynamic> json) {
    return AdminUserFavoriteItemModel(
      trackExternalId: (json['trackExternalId'] ?? '').toString(),
      createdAt:
          AdminUserModel._tryParseDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }
}

class AdminUserPlaylistItemModel extends AdminUserPlaylistItemEntity {
  const AdminUserPlaylistItemModel({
    required super.id,
    required super.name,
    super.description,
    super.coverImageUrl,
    required super.isPublic,
    required super.trackCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory AdminUserPlaylistItemModel.fromJson(Map<String, dynamic> json) {
    return AdminUserPlaylistItemModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: json['description']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      isPublic: json['isPublic'] == true,
      trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
      createdAt:
          AdminUserModel._tryParseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt:
          AdminUserModel._tryParseDateTime(json['updatedAt']) ?? DateTime.now(),
    );
  }
}
