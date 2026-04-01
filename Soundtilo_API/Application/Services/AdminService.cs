using Application.DTOs.Admin;
using Application.DTOs.Subscriptions;
using Domain.Entities;
using Domain.Interfaces;
using System.Linq;

namespace Application.Services;

public class AdminService
{
    private readonly IUserRepository _userRepository;
    private readonly IAdminAuditLogRepository _auditLogRepository;
    private readonly IAdminAnalyticsRepository _analyticsRepository;
    private readonly IHistoryRepository _historyRepository;
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly IPlaylistRepository _playlistRepository;
    private readonly NotificationService _notificationService;
    private readonly ISubscriptionRepository _subscriptionRepository;
    private readonly IPaymentTransactionRepository _paymentTransactionRepository;

    public AdminService(
        IUserRepository userRepository,
        IAdminAuditLogRepository auditLogRepository,
        IAdminAnalyticsRepository analyticsRepository,
        IHistoryRepository historyRepository,
        IFavoriteRepository favoriteRepository,
        IPlaylistRepository playlistRepository,
        NotificationService notificationService,
        ISubscriptionRepository subscriptionRepository,
        IPaymentTransactionRepository paymentTransactionRepository)
    {
        _userRepository = userRepository;
        _auditLogRepository = auditLogRepository;
        _analyticsRepository = analyticsRepository;
        _historyRepository = historyRepository;
        _favoriteRepository = favoriteRepository;
        _playlistRepository = playlistRepository;
        _notificationService = notificationService;
        _subscriptionRepository = subscriptionRepository;
        _paymentTransactionRepository = paymentTransactionRepository;
    }

    // ─── User Management ──────────────────────────────────────────────────────

    public async Task<AdminUserListResponse> GetUsersAsync(
        int page = 1 ,
        int pageSize = 20 ,
        string? search = null ,
        string? role = null ,
        bool? isBanned = null ,
        string? subscriptionTier = null)
    {
        var safePage = Math.Max(page , 1);
        var safePageSize = Math.Clamp(pageSize , 1 , 100);

        var (users, total) = await _userRepository.GetAllAsync(safePage , safePageSize , search , role , isBanned , subscriptionTier);
        var totalPages = (int) Math.Ceiling((double) total / safePageSize);
        var dtos = users.Select(MapToAdminUserDto);

        return new AdminUserListResponse(dtos , total , safePage , safePageSize , totalPages);
    }

    public async Task<AdminUserDetailDto> GetUserDetailAsync(Guid userId)
    {
        var user = await _userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException($"User {userId} not found.");

        var totalListens = await _historyRepository.GetTotalListensAsync(userId);
        var totalTime = await _historyRepository.GetTotalListeningTimeAsync(userId);
        var totalFavorites = await _favoriteRepository.GetCountAsync(userId);
        var playlists = await _playlistRepository.GetByUserIdAsync(userId);

        return new AdminUserDetailDto(
            user.Id ,
            user.Username ,
            user.Email ,
            user.DisplayName ,
            user.AvatarUrl ,
            user.Role ,
            user.IsBanned ,
            user.BannedAt ,
            user.BannedReason ,
            user.CreatedAt ,
            totalListens ,
            totalTime ,
            totalFavorites ,
            playlists.Count() ,
            user.SubscriptionTier ,
            user.PremiumExpiresAt
        );
    }

    public async Task<AdminUserHistoryListResponse> GetUserHistoryAsync(
        Guid userId ,
        int page = 1 ,
        int pageSize = 20)
    {
        await EnsureUserExistsAsync(userId);

        var safePage = Math.Max(page , 1);
        var safePageSize = Math.Clamp(pageSize , 1 , 100);

        var history = await _historyRepository.GetByUserIdAsync(userId , safePage , safePageSize);
        var total = await _historyRepository.GetTotalListensAsync(userId);
        var totalPages = (int) Math.Ceiling((double) total / safePageSize);

        return new AdminUserHistoryListResponse(
            history.Select(h => new AdminUserHistoryItemDto(
                h.Id ,
                h.TrackExternalId ,
                h.ListenedAt ,
                h.DurationListened ,
                h.Completed
            )) ,
            total ,
            safePage ,
            safePageSize ,
            totalPages
        );
    }

    public async Task<AdminUserFavoriteListResponse> GetUserFavoritesAsync(
        Guid userId ,
        int page = 1 ,
        int pageSize = 20)
    {
        await EnsureUserExistsAsync(userId);

        var safePage = Math.Max(page , 1);
        var safePageSize = Math.Clamp(pageSize , 1 , 100);

        var favorites = await _favoriteRepository.GetByUserIdAsync(userId , safePage , safePageSize);
        var total = await _favoriteRepository.GetCountAsync(userId);
        var totalPages = (int) Math.Ceiling((double) total / safePageSize);

        return new AdminUserFavoriteListResponse(
            favorites.Select(f => new AdminUserFavoriteItemDto(
                f.TrackExternalId ,
                f.CreatedAt
            )) ,
            total ,
            safePage ,
            safePageSize ,
            totalPages
        );
    }

    public async Task<AdminUserPlaylistListResponse> GetUserPlaylistsAsync(
        Guid userId ,
        int page = 1 ,
        int pageSize = 20)
    {
        await EnsureUserExistsAsync(userId);

        var safePage = Math.Max(page , 1);
        var safePageSize = Math.Clamp(pageSize , 1 , 100);

        var (playlists, total) = await _playlistRepository.GetPagedByUserIdAsync(userId , safePage , safePageSize);
        var totalPages = (int) Math.Ceiling((double) total / safePageSize);

        return new AdminUserPlaylistListResponse(
            playlists.Select(p => new AdminUserPlaylistItemDto(
                p.Id ,
                p.Name ,
                p.Description ,
                p.CoverImageUrl ,
                p.IsPublic ,
                p.PlaylistTracks.Count ,
                p.CreatedAt ,
                p.UpdatedAt
            )) ,
            total ,
            safePage ,
            safePageSize ,
            totalPages
        );
    }

    public async Task BanUserAsync(Guid adminId , Guid targetUserId , string? reason)
    {
        var user = await _userRepository.GetByIdAsync(targetUserId)
            ?? throw new KeyNotFoundException($"User {targetUserId} not found.");

        if ( user.Role == "admin" )
            throw new InvalidOperationException("Cannot ban an admin account.");

        user.IsBanned = true;
        user.BannedAt = DateTime.UtcNow;
        user.BannedReason = reason;
        await _userRepository.UpdateAsync(user);

        await _auditLogRepository.AddAsync(new AdminAuditLog
        {
            Id = Guid.NewGuid() ,
            AdminId = adminId ,
            Action = "BAN_USER" ,
            TargetType = "User" ,
            TargetId = targetUserId.ToString() ,
            Details = reason != null ? $"{{\"reason\":\"{reason}\"}}" : null ,
            CreatedAt = DateTime.UtcNow
        });

        var message = reason is { Length: > 0 }
            ? $"Tài khoản của bạn đã bị khóa do vi phạm. Lý do: {reason}"
            : "Tài khoản của bạn đã bị khóa do vi phạm chính sách cộng đồng.";
        await _notificationService.SendViolationWarningAsync(adminId , targetUserId , "Cảnh báo vi phạm" , message);
    }

    public async Task UnbanUserAsync(Guid adminId , Guid targetUserId)
    {
        var user = await _userRepository.GetByIdAsync(targetUserId)
            ?? throw new KeyNotFoundException($"User {targetUserId} not found.");

        user.IsBanned = false;
        user.BannedAt = null;
        user.BannedReason = null;
        await _userRepository.UpdateAsync(user);

        await _auditLogRepository.AddAsync(new AdminAuditLog
        {
            Id = Guid.NewGuid() ,
            AdminId = adminId ,
            Action = "UNBAN_USER" ,
            TargetType = "User" ,
            TargetId = targetUserId.ToString() ,
            CreatedAt = DateTime.UtcNow
        });

        await _notificationService.SendToUserAsync(
            adminId ,
            targetUserId ,
            Domain.Enums.NotificationType.UserMessage ,
            Domain.Enums.NotificationSource.Automatic ,
            "Khôi phục tài khoản" ,
            "Tài khoản của bạn đã được mở khóa. Vui lòng tuân thủ chính sách để tránh bị xử lý lại." ,
            null ,
            null);
    }

    public async Task ChangeRoleAsync(Guid adminId , Guid targetUserId , string newRole)
    {
        var allowedRoles = new[] { "user" , "admin" };
        if ( !allowedRoles.Contains(newRole) )
            throw new ArgumentException($"Invalid role '{newRole}'. Allowed: {string.Join(", " , allowedRoles)}.");

        var user = await _userRepository.GetByIdAsync(targetUserId)
            ?? throw new KeyNotFoundException($"User {targetUserId} not found.");

        var previousRole = user.Role;
        user.Role = newRole;
        await _userRepository.UpdateAsync(user);

        await _auditLogRepository.AddAsync(new AdminAuditLog
        {
            Id = Guid.NewGuid() ,
            AdminId = adminId ,
            Action = "CHANGE_ROLE" ,
            TargetType = "User" ,
            TargetId = targetUserId.ToString() ,
            Details = $"{{\"from\":\"{previousRole}\",\"to\":\"{newRole}\"}}" ,
            CreatedAt = DateTime.UtcNow
        });
    }

    public async Task DeleteUserAsync(Guid adminId , Guid targetUserId)
    {
        var user = await _userRepository.GetByIdAsync(targetUserId)
            ?? throw new KeyNotFoundException($"User {targetUserId} not found.");

        if ( user.Role == "admin" )
            throw new InvalidOperationException("Cannot delete an admin account.");

        await _userRepository.DeleteAsync(user);

        await _auditLogRepository.AddAsync(new AdminAuditLog
        {
            Id = Guid.NewGuid() ,
            AdminId = adminId ,
            Action = "DELETE_USER" ,
            TargetType = "User" ,
            TargetId = targetUserId.ToString() ,
            Details = $"{{\"username\":\"{user.Username}\",\"email\":\"{user.Email}\"}}" ,
            CreatedAt = DateTime.UtcNow
        });
    }

    // ─── Premium Management ───────────────────────────────────────────────────

    public async Task GrantPremiumAsync(Guid adminId , Guid targetUserId , DateTime? expiresAt)
    {
        var user = await _userRepository.GetByIdAsync(targetUserId)
            ?? throw new KeyNotFoundException($"User {targetUserId} not found.");

        var premiumEnd = expiresAt ?? DateTime.UtcNow.AddMonths(1);
        user.SubscriptionTier = "premium";
        user.PremiumExpiresAt = premiumEnd;
        user.UpdatedAt = DateTime.UtcNow;
        await _userRepository.UpdateAsync(user);

        // Upsert subscription record
        var existingSub = await _subscriptionRepository.GetByUserIdAsync(targetUserId);
        if ( existingSub is not null )
        {
            existingSub.Status = "manually_granted";
            existingSub.CurrentPeriodEnd = premiumEnd;
            existingSub.CancelledAt = null;
            await _subscriptionRepository.UpdateAsync(existingSub);
        }
        else
        {
            // Look up the default premium plan (monthly) for the FK
            var plans = await _subscriptionRepository.GetActivePlansAsync();
            var premiumPlan = plans.FirstOrDefault(p => p.Interval == "monthly")
                ?? plans.FirstOrDefault(p => p.Interval != "free")
                ?? throw new InvalidOperationException("No active premium plan found. Please seed subscription plans first.");

            await _subscriptionRepository.CreateAsync(new Subscription
            {
                Id = Guid.NewGuid() ,
                UserId = targetUserId ,
                PlanId = premiumPlan.Id , 
                Status = "manually_granted" ,
                CurrentPeriodStart = DateTime.UtcNow ,
                CurrentPeriodEnd = premiumEnd ,
                CreatedAt = DateTime.UtcNow
            });
        }

        await _auditLogRepository.AddAsync(new AdminAuditLog
        {
            Id = Guid.NewGuid() ,
            AdminId = adminId ,
            Action = "GRANT_PREMIUM" ,
            TargetType = "User" ,
            TargetId = targetUserId.ToString() ,
            Details = $"{{\"expiresAt\":\"{premiumEnd:O}\"}}" ,
            CreatedAt = DateTime.UtcNow
        });
    }

    public async Task RevokePremiumAsync(Guid adminId , Guid targetUserId)
    {
        var user = await _userRepository.GetByIdAsync(targetUserId)
            ?? throw new KeyNotFoundException($"User {targetUserId} not found.");

        if ( user.SubscriptionTier == "free" )
            throw new InvalidOperationException("User is already on the free tier.");

        user.SubscriptionTier = "free";
        user.PremiumExpiresAt = null;
        user.UpdatedAt = DateTime.UtcNow;
        await _userRepository.UpdateAsync(user);

        var existingSub = await _subscriptionRepository.GetByUserIdAsync(targetUserId);
        if ( existingSub is not null )
        {
            existingSub.Status = "cancelled";
            existingSub.CancelledAt = DateTime.UtcNow;
            await _subscriptionRepository.UpdateAsync(existingSub);
        }

        await _auditLogRepository.AddAsync(new AdminAuditLog
        {
            Id = Guid.NewGuid() ,
            AdminId = adminId ,
            Action = "REVOKE_PREMIUM" ,
            TargetType = "User" ,
            TargetId = targetUserId.ToString() ,
            CreatedAt = DateTime.UtcNow
        });
    }

    public async Task<AdminSubscriptionStatsDto> GetSubscriptionStatsAsync()
    {
        var totalPremium = await _subscriptionRepository.CountPremiumUsersAsync();
        var totalUsers = await _userRepository.CountAsync();
        var totalFree = totalUsers - totalPremium;
        var (subs, activeCount) = await _subscriptionRepository.GetAllAsync(1 , 1 , "active");
        var (manualSubs, manualCount) = await _subscriptionRepository.GetAllAsync(1 , 1 , "manually_granted");
        var totalRevenue = await _paymentTransactionRepository.GetTotalRevenueAsync();

        return new AdminSubscriptionStatsDto(
            totalPremium ,
            totalFree ,
            activeCount + manualCount ,
            totalRevenue
        );
    }

    // ─── Analytics ────────────────────────────────────────────────────────────

    public async Task<AdminAnalyticsOverviewDto> GetAnalyticsOverviewAsync()
    {
        var now = DateTime.UtcNow;
        var sevenDaysAgo = now.AddDays(-7);

        var (totalUsers, totalBanned, totalAdmins, newUsersLast7Days, totalListeningTime, totalTracks, totalPlaylists) = (
            await _userRepository.CountAsync(),
            await _analyticsRepository.CountBannedUsersAsync(),
            await _analyticsRepository.CountUsersByRoleAsync("admin"),
            await _analyticsRepository.CountNewUsersSinceAsync(sevenDaysAgo),
            await _analyticsRepository.SumListeningTimeSecondsAsync(),
            await _analyticsRepository.CountCachedTracksAsync(),
            await _analyticsRepository.CountPlaylistsAsync()
        );

        return new AdminAnalyticsOverviewDto(
            totalUsers ,
            totalBanned ,
            totalAdmins ,
            newUsersLast7Days ,
            totalListeningTime ,
            totalTracks ,
            totalPlaylists
        );
    }

    public async Task<IEnumerable<TopTrackDto>> GetTopTracksAsync(int count = 10)
    {
        var tracks = await _analyticsRepository.GetTopTracksAsync(count);
        return tracks.Select(t => new TopTrackDto(t.TrackExternalId , t.Title , t.Artist , t.PlayCount));
    }

    public async Task<IEnumerable<DailyStatsDto>> GetDailyStatsAsync(DateOnly from , DateOnly to)
    {
        if ( to < from )
            throw new ArgumentException("'to' must be on or after 'from'.");

        if ( (to.ToDateTime(TimeOnly.MinValue) - from.ToDateTime(TimeOnly.MinValue)).TotalDays > 365 )
            throw new ArgumentException("Date range cannot exceed 365 days.");

        var rows = await _analyticsRepository.GetDailyStatsAsync(from , to);
        return rows.Select(r => new DailyStatsDto(r.Date , r.NewUsers , r.TotalListens , r.TotalListeningSeconds));
    }

    // ─── Private helpers ──────────────────────────────────────────────────────

    private static AdminUserDto MapToAdminUserDto(User user) => new(
        user.Id ,
        user.Username ,
        user.Email ,
        user.DisplayName ,
        user.AvatarUrl ,
        user.Role ,
        user.IsBanned ,
        user.BannedAt ,
        user.BannedReason ,
        user.CreatedAt ,
        user.SubscriptionTier ,
        user.PremiumExpiresAt
    );

    private async Task EnsureUserExistsAsync(Guid userId)
    {
        _ = await _userRepository.GetByIdAsync(userId)
            ?? throw new KeyNotFoundException($"User {userId} not found.");
    }
}
