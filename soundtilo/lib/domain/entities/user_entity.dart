import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? role;
  final DateTime createdAt;
  final String subscriptionTier;
  final DateTime? premiumExpiresAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.role,
    required this.createdAt,
    this.subscriptionTier = 'free',
    this.premiumExpiresAt,
  });

  /// True when the user holds an active premium subscription.
  /// Checks both the tier value and that the expiry (if set) has not passed.
  bool get isPremium =>
      subscriptionTier == 'premium' &&
      (premiumExpiresAt == null || premiumExpiresAt!.isAfter(DateTime.now()));

  // HÀM COPYWITH ĐƯỢC THÊM VÀO ĐÂY Ạ
  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        displayName,
        avatarUrl,
        role,
        createdAt,
        subscriptionTier,
        premiumExpiresAt,
      ];
}
