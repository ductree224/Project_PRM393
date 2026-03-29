namespace Application.DTOs.Users;

public record UserBadgeDto(
    Guid Id,
    string Code,
    string Name,
    string? Description,
    string? IconUrl,
    DateTime AssignedAt,
    string? Note
);

public record ProfileBadgeCatalogDto(
    Guid Id,
    string Code,
    string Name,
    string? Description,
    string? IconUrl,
    bool IsActive
);

public record BlockedUserDto(
    Guid UserId,
    string Username,
    string? DisplayName,
    string? AvatarUrl,
    string? Reason,
    DateTime BlockedAt
);

public record UserProfileDto(
    Guid Id,
    string Username,
    string Email,
    string? DisplayName,
    string? AvatarUrl,
    string? Bio,
    DateTime? Birthday,
    string? Gender,
    string? Pronouns,
    string? StatusMessage,
    bool IsProfilePublic,
    bool AllowComments,
    bool AllowMessages,
    string FollowerPrivacyMode,
    string ThemeMode,
    bool ShowTotalListens,
    bool ShowTotalFavorites,
    bool ShowTotalPlaylists,
    bool ShowListeningTime,
    bool ShowRecentlyPlayed,
    DateTime CreatedAt,
    int TotalListens,
    int TotalListeningTimeSeconds,
    int TotalFavorites,
    int TotalPlaylists,
    string SubscriptionTier,
    DateTime? PremiumExpiresAt,
    IEnumerable<UserBadgeDto> Badges
);

public record UpdateProfileRequest(
    string? DisplayName = null,
    string? AvatarUrl = null,
    string? Bio = null,
    DateTime? Birthday = null,
    string? Gender = null,
    string? Pronouns = null,
    string? StatusMessage = null,
    bool? IsProfilePublic = null,
    bool? AllowComments = null,
    bool? AllowMessages = null,
    string? FollowerPrivacyMode = null,
    string? ThemeMode = null,
    bool? ShowTotalListens = null,
    bool? ShowTotalFavorites = null,
    bool? ShowTotalPlaylists = null,
    bool? ShowListeningTime = null,
    bool? ShowRecentlyPlayed = null
);

public record BlockUserRequest(
    Guid BlockedUserId,
    string? Reason
);

public record CreateProfileBadgeRequest(
    string Code,
    string Name,
    string? Description,
    string? IconUrl,
    bool IsActive = true
);

public record AssignBadgeRequest(
    Guid BadgeId,
    string? Note
);
