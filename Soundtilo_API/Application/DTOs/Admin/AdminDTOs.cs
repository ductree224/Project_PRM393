namespace Application.DTOs.Admin;

public record AdminUserDto(
    Guid Id,
    string Username,
    string Email,
    string? DisplayName,
    string? AvatarUrl,
    string Role,
    bool IsBanned,
    DateTime? BannedAt,
    string? BannedReason,
    DateTime CreatedAt,
    string SubscriptionTier,
    DateTime? PremiumExpiresAt
);

public record AdminUserDetailDto(
    Guid Id,
    string Username,
    string Email,
    string? DisplayName,
    string? AvatarUrl,
    string Role,
    bool IsBanned,
    DateTime? BannedAt,
    string? BannedReason,
    DateTime CreatedAt,
    int TotalListens,
    int TotalListeningTimeSeconds,
    int TotalFavorites,
    int TotalPlaylists,
    string SubscriptionTier,
    DateTime? PremiumExpiresAt
);

public record AdminUserListResponse(
    IEnumerable<AdminUserDto> Users,
    int Total,
    int Page,
    int PageSize,
    int TotalPages
);

public record AdminUserHistoryItemDto(
    Guid Id,
    string TrackExternalId,
    DateTime ListenedAt,
    int DurationListened,
    bool Completed
);

public record AdminUserHistoryListResponse(
    IEnumerable<AdminUserHistoryItemDto> History,
    int Total,
    int Page,
    int PageSize,
    int TotalPages
);

public record AdminUserFavoriteItemDto(
    string TrackExternalId,
    DateTime CreatedAt
);

public record AdminUserFavoriteListResponse(
    IEnumerable<AdminUserFavoriteItemDto> Favorites,
    int Total,
    int Page,
    int PageSize,
    int TotalPages
);

public record AdminUserPlaylistItemDto(
    Guid Id,
    string Name,
    string? Description,
    string? CoverImageUrl,
    bool IsPublic,
    int TrackCount,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public record AdminUserPlaylistListResponse(
    IEnumerable<AdminUserPlaylistItemDto> Playlists,
    int Total,
    int Page,
    int PageSize,
    int TotalPages
);

public record BanUserRequest(
    string? Reason
);

public record ChangeRoleRequest(
    string Role
);

public record GrantPremiumRequest(
    DateTime? ExpiresAt
);

public record AdminSubscriptionStatsDto(
    int TotalPremiumUsers,
    int TotalFreeUsers,
    int ActiveSubscriptions,
    decimal TotalRevenue
);

public record AdminAnalyticsOverviewDto(
    int TotalUsers,
    int TotalBannedUsers,
    int TotalAdmins,
    int NewUsersLast7Days,
    long TotalListeningTimeSeconds,
    int TotalTracks,
    int TotalPlaylists
);

public record TopTrackDto(
    string TrackId,
    string Title,
    string Artist,
    int PlayCount
);

public record DailyStatsDto(
    DateOnly Date,
    int NewUsers,
    int TotalListens,
    long TotalListeningTimeSeconds
);

public record AdminAuditLogDto(
    Guid Id,
    Guid AdminId,
    string AdminUsername,
    string Action,
    string? TargetType,
    string? TargetId,
    string? Details,
    DateTime CreatedAt
);
