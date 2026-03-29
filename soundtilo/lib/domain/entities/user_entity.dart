import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final DateTime? birthday;
  final String? gender;
  final String? pronouns;
  final bool? isProfilePublic;
  final String? statusMessage;
  final bool? allowComments;
  final bool? allowMessages;
  final String? followerPrivacyMode;
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
    this.bio,
    this.birthday,
    this.gender,
    this.pronouns,
    this.isProfilePublic,
    this.statusMessage,
    this.allowComments,
    this.allowMessages,
    this.followerPrivacyMode,
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

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    displayName,
    avatarUrl,
    bio,
    birthday,
    gender,
    pronouns,
    isProfilePublic,
    statusMessage,
    allowComments,
    allowMessages,
    followerPrivacyMode,
    role,
    createdAt,
    subscriptionTier,
    premiumExpiresAt,
  ];
}
