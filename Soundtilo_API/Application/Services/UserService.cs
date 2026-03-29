using Application.DTOs.Users;
using Domain.Entities;
using Domain.Interfaces;

namespace Application.Services;

public class UserService
{
    private static readonly HashSet<string> ValidFollowerPrivacyModes = new(StringComparer.OrdinalIgnoreCase)
    {
        "everyone",
        "followers_only",
        "private"
    };

    private static readonly HashSet<string> ValidThemeModes = new(StringComparer.OrdinalIgnoreCase)
    {
        "system",
        "light",
        "dark"
    };

    private readonly IUserRepository _userRepository;
    private readonly IHistoryRepository _historyRepository;
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly IPlaylistRepository _playlistRepository;
    private readonly IUserSettingRepository _userSettingRepository;
    private readonly IUserBlockRepository _userBlockRepository;
    private readonly IProfileBadgeRepository _profileBadgeRepository;
    private readonly IUserBadgeRepository _userBadgeRepository;

    public UserService(
        IUserRepository userRepository,
        IHistoryRepository historyRepository,
        IFavoriteRepository favoriteRepository,
        IPlaylistRepository playlistRepository,
        IUserSettingRepository userSettingRepository,
        IUserBlockRepository userBlockRepository,
        IProfileBadgeRepository profileBadgeRepository,
        IUserBadgeRepository userBadgeRepository)
    {
        _userRepository = userRepository;
        _historyRepository = historyRepository;
        _favoriteRepository = favoriteRepository;
        _playlistRepository = playlistRepository;
        _userSettingRepository = userSettingRepository;
        _userBlockRepository = userBlockRepository;
        _profileBadgeRepository = profileBadgeRepository;
        _userBadgeRepository = userBadgeRepository;
    }

    public async Task<UserProfileDto?> GetProfileAsync(Guid userId)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return null;

        var settings = await GetOrCreateUserSettingAsync(userId);
        var badges = await _userBadgeRepository.GetByUserIdAsync(userId);

        var totalListens = await _historyRepository.GetTotalListensAsync(userId);
        var totalTime = await _historyRepository.GetTotalListeningTimeAsync(userId);
        var totalFavorites = await _favoriteRepository.GetCountAsync(userId);
        var playlists = await _playlistRepository.GetByUserIdAsync(userId);

        return new UserProfileDto(
            Id: user.Id,
            Username: user.Username,
            Email: user.Email,
            DisplayName: user.DisplayName,
            AvatarUrl: user.AvatarUrl,
            Bio: user.Bio,
            Birthday: user.Birthday,
            Gender: user.Gender,
            Pronouns: user.Pronouns,
            StatusMessage: user.StatusMessage,
            IsProfilePublic: user.IsProfilePublic,
            AllowComments: user.AllowComments,
            AllowMessages: user.AllowMessages,
            FollowerPrivacyMode: user.FollowerPrivacyMode,
            ThemeMode: settings.ThemeMode,
            ShowTotalListens: settings.ShowTotalListens,
            ShowTotalFavorites: settings.ShowTotalFavorites,
            ShowTotalPlaylists: settings.ShowTotalPlaylists,
            ShowListeningTime: settings.ShowListeningTime,
            ShowRecentlyPlayed: settings.ShowRecentlyPlayed,
            CreatedAt: user.CreatedAt,
            TotalListens: totalListens,
            TotalListeningTimeSeconds: totalTime,
            TotalFavorites: totalFavorites,
            TotalPlaylists: playlists.Count(),
            SubscriptionTier: user.SubscriptionTier,
            PremiumExpiresAt: user.PremiumExpiresAt,
            Badges: badges.Select(b => new UserBadgeDto(
                b.BadgeId,
                b.Badge.Code,
                b.Badge.Name,
                b.Badge.Description,
                b.Badge.IconUrl,
                b.AssignedAt,
                b.Note
            ))
        );
    }

    public async Task<UserProfileDto?> UpdateProfileAsync(Guid userId, UpdateProfileRequest request)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return null;

        var settings = await GetOrCreateUserSettingAsync(userId);

        if (request.DisplayName != null)
        {
            var normalized = NormalizeNullable(request.DisplayName, 100);
            user.DisplayName = normalized;
        }

        if (request.AvatarUrl != null)
        {
            user.AvatarUrl = NormalizeNullable(request.AvatarUrl, 1000);
        }

        if (request.Bio != null)
        {
            user.Bio = NormalizeNullable(request.Bio, 500);
        }

        if (request.Birthday.HasValue)
        {
            if (request.Birthday.Value.Date > DateTime.UtcNow.Date)
            {
                throw new ArgumentException("Ngày sinh không hợp lệ.");
            }

            user.Birthday = request.Birthday.Value.Date;
        }

        if (request.Gender != null)
        {
            user.Gender = NormalizeNullable(request.Gender, 30);
        }

        if (request.Pronouns != null)
        {
            user.Pronouns = NormalizeNullable(request.Pronouns, 30);
        }

        if (request.StatusMessage != null)
        {
            user.StatusMessage = NormalizeNullable(request.StatusMessage, 160);
        }

        if (request.IsProfilePublic.HasValue)
        {
            user.IsProfilePublic = request.IsProfilePublic.Value;
        }

        if (request.AllowComments.HasValue)
        {
            user.AllowComments = request.AllowComments.Value;
        }

        if (request.AllowMessages.HasValue)
        {
            user.AllowMessages = request.AllowMessages.Value;
        }

        if (!string.IsNullOrWhiteSpace(request.FollowerPrivacyMode))
        {
            var normalizedMode = request.FollowerPrivacyMode.Trim().ToLowerInvariant();
            if (!ValidFollowerPrivacyModes.Contains(normalizedMode))
            {
                throw new ArgumentException("Follower privacy mode không hợp lệ.");
            }

            user.FollowerPrivacyMode = normalizedMode;
        }

        if (!string.IsNullOrWhiteSpace(request.ThemeMode))
        {
            var normalizedTheme = request.ThemeMode.Trim().ToLowerInvariant();
            if (!ValidThemeModes.Contains(normalizedTheme))
            {
                throw new ArgumentException("Theme mode không hợp lệ.");
            }

            settings.ThemeMode = normalizedTheme;
        }

        if (request.ShowTotalListens.HasValue) settings.ShowTotalListens = request.ShowTotalListens.Value;
        if (request.ShowTotalFavorites.HasValue) settings.ShowTotalFavorites = request.ShowTotalFavorites.Value;
        if (request.ShowTotalPlaylists.HasValue) settings.ShowTotalPlaylists = request.ShowTotalPlaylists.Value;
        if (request.ShowListeningTime.HasValue) settings.ShowListeningTime = request.ShowListeningTime.Value;
        if (request.ShowRecentlyPlayed.HasValue) settings.ShowRecentlyPlayed = request.ShowRecentlyPlayed.Value;

        await _userRepository.UpdateAsync(user);
        await _userSettingRepository.UpdateAsync(settings);

        return await GetProfileAsync(userId);
    }

    public async Task<IEnumerable<BlockedUserDto>> GetBlockedUsersAsync(Guid userId)
    {
        var blocks = await _userBlockRepository.GetBlockedUsersAsync(userId);
        return blocks.Select(b => new BlockedUserDto(
            b.BlockedId,
            b.Blocked.Username,
            b.Blocked.DisplayName,
            b.Blocked.AvatarUrl,
            b.Reason,
            b.CreatedAt
        ));
    }

    public async Task<bool> BlockUserAsync(Guid blockerUserId, BlockUserRequest request)
    {
        if (request.BlockedUserId == blockerUserId)
        {
            throw new ArgumentException("Không thể chặn chính mình.");
        }

        var blockedUser = await _userRepository.GetByIdAsync(request.BlockedUserId);
        if (blockedUser == null)
        {
            return false;
        }

        var existing = await _userBlockRepository.GetByBlockerAndBlockedAsync(blockerUserId, request.BlockedUserId);
        if (existing != null)
        {
            return true;
        }

        await _userBlockRepository.CreateAsync(new UserBlock
        {
            Id = Guid.NewGuid(),
            BlockerId = blockerUserId,
            BlockedId = request.BlockedUserId,
            Reason = NormalizeNullable(request.Reason, 250),
            CreatedAt = DateTime.UtcNow
        });

        return true;
    }

    public async Task<bool> UnblockUserAsync(Guid blockerUserId, Guid blockedUserId)
    {
        var block = await _userBlockRepository.GetByBlockerAndBlockedAsync(blockerUserId, blockedUserId);
        if (block == null)
        {
            return false;
        }

        await _userBlockRepository.DeleteAsync(block);
        return true;
    }

    public async Task<IEnumerable<UserBadgeDto>> GetUserBadgesAsync(Guid userId)
    {
        var badges = await _userBadgeRepository.GetByUserIdAsync(userId);
        return badges.Select(b => new UserBadgeDto(
            b.BadgeId,
            b.Badge.Code,
            b.Badge.Name,
            b.Badge.Description,
            b.Badge.IconUrl,
            b.AssignedAt,
            b.Note
        ));
    }

    public async Task<IEnumerable<ProfileBadgeCatalogDto>> GetBadgeCatalogAsync(bool activeOnly = false)
    {
        var badges = await _profileBadgeRepository.GetAllAsync(activeOnly);
        return badges.Select(b => new ProfileBadgeCatalogDto(
            b.Id,
            b.Code,
            b.Name,
            b.Description,
            b.IconUrl,
            b.IsActive
        ));
    }

    public async Task<ProfileBadgeCatalogDto> CreateBadgeAsync(CreateProfileBadgeRequest request)
    {
        var code = request.Code.Trim().ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(code) || code.Length > 50)
        {
            throw new ArgumentException("Code badge không hợp lệ.");
        }

        var existing = await _profileBadgeRepository.GetByCodeAsync(code);
        if (existing != null)
        {
            throw new InvalidOperationException("Code badge đã tồn tại.");
        }

        var name = request.Name.Trim();
        if (string.IsNullOrWhiteSpace(name) || name.Length > 80)
        {
            throw new ArgumentException("Tên badge không hợp lệ.");
        }

        var badge = await _profileBadgeRepository.CreateAsync(new ProfileBadge
        {
            Id = Guid.NewGuid(),
            Code = code,
            Name = name,
            Description = NormalizeNullable(request.Description, 250),
            IconUrl = NormalizeNullable(request.IconUrl, 1000),
            IsActive = request.IsActive,
            CreatedAt = DateTime.UtcNow
        });

        return new ProfileBadgeCatalogDto(
            badge.Id,
            badge.Code,
            badge.Name,
            badge.Description,
            badge.IconUrl,
            badge.IsActive
        );
    }

    public async Task<bool> AssignBadgeAsync(Guid adminId, Guid targetUserId, AssignBadgeRequest request)
    {
        var user = await _userRepository.GetByIdAsync(targetUserId);
        if (user == null)
        {
            return false;
        }

        var badge = await _profileBadgeRepository.GetByIdAsync(request.BadgeId);
        if (badge == null || !badge.IsActive)
        {
            throw new ArgumentException("Badge không hợp lệ hoặc đã bị vô hiệu hoá.");
        }

        var existing = await _userBadgeRepository.GetByUserAndBadgeAsync(targetUserId, request.BadgeId);
        if (existing != null)
        {
            return true;
        }

        await _userBadgeRepository.CreateAsync(new UserBadge
        {
            Id = Guid.NewGuid(),
            UserId = targetUserId,
            BadgeId = request.BadgeId,
            AssignedByAdminId = adminId,
            AssignedAt = DateTime.UtcNow,
            Note = NormalizeNullable(request.Note, 250)
        });

        return true;
    }

    public async Task<bool> RemoveBadgeAsync(Guid targetUserId, Guid badgeId)
    {
        var existing = await _userBadgeRepository.GetByUserAndBadgeAsync(targetUserId, badgeId);
        if (existing == null)
        {
            return false;
        }

        await _userBadgeRepository.DeleteAsync(existing);
        return true;
    }

    private async Task<UserSetting> GetOrCreateUserSettingAsync(Guid userId)
    {
        var settings = await _userSettingRepository.GetByUserIdAsync(userId);
        if (settings != null)
        {
            return settings;
        }

        return await _userSettingRepository.CreateAsync(new UserSetting
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            ThemeMode = "system",
            AudioQuality = "medium",
            ShowTotalListens = true,
            ShowTotalFavorites = true,
            ShowTotalPlaylists = true,
            ShowListeningTime = true,
            ShowRecentlyPlayed = true,
            UpdatedAt = DateTime.UtcNow
        });
    }

    private static string? NormalizeNullable(string? value, int maxLength)
    {
        if (value == null)
        {
            return null;
        }

        var normalized = value.Trim();
        if (normalized.Length == 0)
        {
            return null;
        }

        if (normalized.Length > maxLength)
        {
            throw new ArgumentException($"Giá trị vượt quá {maxLength} ký tự.");
        }

        return normalized;
    }
}
