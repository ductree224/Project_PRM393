using Application.Services;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Services;

public class NotificationDispatchBackgroundService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<NotificationDispatchBackgroundService> _logger;

    private static readonly TimeSpan PollInterval = TimeSpan.FromSeconds(20);
    private const int BatchSize = 50;

    // Run subscription expiry check every ~6 hours (1080 ticks × 20s = 21600s = 6h)
    private const int ExpiryCheckIntervalTicks = 1080;
    private int _tickCounter;

    public NotificationDispatchBackgroundService(
        IServiceScopeFactory scopeFactory,
        ILogger<NotificationDispatchBackgroundService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("Notification dispatcher background service started.");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _scopeFactory.CreateScope();
                var scheduler = scope.ServiceProvider.GetRequiredService<NotificationSchedulerService>();
                var notificationService = scope.ServiceProvider.GetRequiredService<NotificationService>();

                var processed = await scheduler.DispatchDueSchedulesAsync(BatchSize, stoppingToken);
                var cleaned = await notificationService.CleanupExpiredNotificationsAsync();

                if (processed > 0 || cleaned > 0)
                {
                    _logger.LogInformation("Notification dispatcher tick: processedSchedules={Processed}, cleanedExpired={Cleaned}", processed, cleaned);
                }

                // Subscription expiry check + auto-downgrade (every ~6 hours)
                _tickCounter++;
                if (_tickCounter >= ExpiryCheckIntervalTicks)
                {
                    _tickCounter = 0;
                    try
                    {
                        var expiryService = scope.ServiceProvider.GetRequiredService<SubscriptionExpiryNotificationService>();
                        var notified = await expiryService.CheckAndNotifyExpiringSubscriptionsAsync(stoppingToken);
                        var downgraded = await expiryService.DowngradeExpiredSubscriptionsAsync(stoppingToken);

                        if (notified > 0 || downgraded > 0)
                        {
                            _logger.LogInformation("Subscription expiry check: notified={Notified}, downgraded={Downgraded}", notified, downgraded);
                        }
                    }
                    catch (Exception expiryEx)
                    {
                        _logger.LogError(expiryEx, "Subscription expiry check failed.");
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Notification dispatcher tick failed.");
            }

            await Task.Delay(PollInterval, stoppingToken);
        }
    }
}
