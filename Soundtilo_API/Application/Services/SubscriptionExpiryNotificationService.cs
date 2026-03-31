using Domain.Enums;
using Domain.Interfaces;
using Microsoft.Extensions.Logging;

namespace Application.Services;

public class SubscriptionExpiryNotificationService
{
    private readonly ISubscriptionRepository _subscriptionRepository;
    private readonly INotificationRepository _notificationRepository;
    private readonly IUserRepository _userRepository;
    private readonly NotificationService _notificationService;
    private readonly ILogger<SubscriptionExpiryNotificationService> _logger;

    private static readonly TimeSpan DeduplicationWindow = TimeSpan.FromDays(7);
    private const int ExpiryWarningDays = 10;

    public SubscriptionExpiryNotificationService(
        ISubscriptionRepository subscriptionRepository,
        INotificationRepository notificationRepository,
        IUserRepository userRepository,
        NotificationService notificationService,
        ILogger<SubscriptionExpiryNotificationService> logger)
    {
        _subscriptionRepository = subscriptionRepository;
        _notificationRepository = notificationRepository;
        _userRepository = userRepository;
        _notificationService = notificationService;
        _logger = logger;
    }

    /// <summary>
    /// Finds active subscriptions expiring within 10 days and sends a notification
    /// if one hasn't been sent within the last 7 days.
    /// </summary>
    public async Task<int> CheckAndNotifyExpiringSubscriptionsAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var expiryCutoff = now.AddDays(ExpiryWarningDays);

        var expiringSubscriptions = await _subscriptionRepository.GetExpiringSubscriptionsAsync(now, expiryCutoff);
        var notified = 0;

        foreach (var sub in expiringSubscriptions)
        {
            if (cancellationToken.IsCancellationRequested) break;

            var alreadyNotified = await _notificationRepository.HasRecentNotificationAsync(
                sub.UserId, NotificationType.SubscriptionExpiry, DeduplicationWindow);

            if (alreadyNotified) continue;

            var daysLeft = (int)Math.Ceiling((sub.CurrentPeriodEnd - now).TotalDays);
            var expiryDateVn = sub.CurrentPeriodEnd.AddHours(7).ToString("dd/MM/yyyy");

            await _notificationService.SendToUserAsync(
                actorAdminId: Guid.Empty,
                userId: sub.UserId,
                type: NotificationType.SubscriptionExpiry,
                source: NotificationSource.Automatic,
                title: "Gói Premium sắp hết hạn",
                message: $"Gói Premium của bạn sẽ hết hạn sau {daysLeft} ngày (ngày {expiryDateVn}). Hãy gia hạn để tiếp tục trải nghiệm đầy đủ!",
                metadataJson: $"{{\"subscriptionId\":\"{sub.Id}\",\"daysLeft\":{daysLeft}}}",
                expiresAt: sub.CurrentPeriodEnd,
                cancellationToken: cancellationToken);

            notified++;
        }

        if (notified > 0)
        {
            _logger.LogInformation("Sent {Count} subscription expiry notifications.", notified);
        }

        return notified;
    }

    /// <summary>
    /// Downgrades users whose premium subscription has expired.
    /// Sets User.SubscriptionTier to "free" and Subscription.Status to "expired".
    /// </summary>
    public async Task<int> DowngradeExpiredSubscriptionsAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        // Get subscriptions that are still "active" but have ended
        var expiredSubscriptions = await _subscriptionRepository.GetExpiringSubscriptionsAsync(
            DateTime.MinValue, now);

        var downgraded = 0;

        foreach (var sub in expiredSubscriptions)
        {
            if (cancellationToken.IsCancellationRequested) break;

            // Only downgrade if truly expired (CurrentPeriodEnd < now)
            if (sub.CurrentPeriodEnd >= now) continue;

            sub.Status = "expired";
            await _subscriptionRepository.UpdateAsync(sub);

            if (sub.User is not null)
            {
                sub.User.SubscriptionTier = "free";
                sub.User.PremiumExpiresAt = null;
                sub.User.UpdatedAt = now;
                await _userRepository.UpdateAsync(sub.User);
            }

            downgraded++;
        }

        if (downgraded > 0)
        {
            _logger.LogInformation("Downgraded {Count} expired subscriptions to free tier.", downgraded);
        }

        return downgraded;
    }
}
