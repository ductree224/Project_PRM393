import 'package:soundtilo/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.displayName,
    super.avatarUrl,
    super.role,
    required super.createdAt,
    super.subscriptionTier = 'free',
    super.premiumExpiresAt,
    super.bio,
    super.birthday,
    super.gender,
    super.pronouns,
    super.isProfilePublic,
    super.statusMessage,
    super.allowComments,
    super.allowMessages,
    super.followerPrivacyMode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      bio: json['bio']?.toString(),
      birthday: json['birthday'] != null
          ? DateTime.tryParse(json['birthday'].toString())?.toLocal()
          : null,
      gender: json['gender']?.toString(),
      pronouns: json['pronouns']?.toString(),
      isProfilePublic: json['isProfilePublic'] == null
          ? null
          : (json['isProfilePublic'] is bool
                ? json['isProfilePublic']
                : json['isProfilePublic'].toString().toLowerCase() == 'true'),
      statusMessage: json['statusMessage']?.toString(),
      allowComments: json['allowComments'] == null
          ? null
          : (json['allowComments'] is bool
                ? json['allowComments']
                : json['allowComments'].toString().toLowerCase() == 'true'),
      allowMessages: json['allowMessages'] == null
          ? null
          : (json['allowMessages'] is bool
                ? json['allowMessages']
                : json['allowMessages'].toString().toLowerCase() == 'true'),
      followerPrivacyMode: json['followerPrivacyMode']?.toString(),
      role: json['role']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      subscriptionTier: (json['subscriptionTier'] ?? 'free').toString(),
      premiumExpiresAt: json['premiumExpiresAt'] != null
          ? DateTime.tryParse(json['premiumExpiresAt'].toString())?.toLocal()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'birthday': birthday?.toIso8601String(),
      'gender': gender,
      'pronouns': pronouns,
      'isProfilePublic': isProfilePublic,
      'statusMessage': statusMessage,
      'allowComments': allowComments,
      'allowMessages': allowMessages,
      'followerPrivacyMode': followerPrivacyMode,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
