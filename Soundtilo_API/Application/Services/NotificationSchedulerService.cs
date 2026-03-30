using Domain.Enums;
using Domain.Interfaces;

namespace Application.Services;

public class NotificationSchedulerService
{
    private readonly INotificationScheduleRepository _scheduleRepository;
    private readonly NotificationService _notificationService;

    public NotificationSchedulerService(
        INotificationScheduleRepository scheduleRepository,
        NotificationService notificationService)
    {
        _scheduleRepository = scheduleRepository;
        _notificationService = notificationService;
    }

    public async Task<int> DispatchDueSchedulesAsync(int batchSize, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var due = await _scheduleRepository.GetDuePendingAsync(now, batchSize);
        var processed = 0;

        foreach (var schedule in due)
        {
            if (cancellationToken.IsCancellationRequested)
            {
                break;
            }

            var acquired = await _scheduleRepository.TryAcquireAsync(schedule.Id, DateTime.UtcNow);
            if (!acquired)
            {
                continue;
            }

            processed++;
            try
            {
                if (schedule.TargetScope == NotificationTargetScope.User)
                {
                    if (!schedule.TargetUserId.HasValue)
                    {
                        throw new InvalidOperationException("Schedule target user is missing.");
                    }

                    await _notificationService.SendToUserAsync(
                        schedule.CreatedByAdminId,
                        schedule.TargetUserId.Value,
                        schedule.Type,
                        NotificationSource.Scheduled,
                        schedule.Title,
                        schedule.Message,
                        schedule.MetadataJson,
                        null,
                        schedule.Id,
                        cancellationToken);
                }
                else
                {
                    await _notificationService.SendBroadcastAsync(
                        schedule.CreatedByAdminId,
                        schedule.Type,
                        NotificationSource.Scheduled,
                        schedule.Title,
                        schedule.Message,
                        schedule.MetadataJson,
                        null,
                        schedule.Id,
                        cancellationToken);
                }

                schedule.ProcessedAt = DateTime.UtcNow;
                schedule.Attempts += 1;
                schedule.LastError = null;

                if (schedule.Recurrence == NotificationRecurrence.OneTime)
                {
                    schedule.Status = NotificationScheduleStatus.Sent;
                }
                else
                {
                    schedule.Status = NotificationScheduleStatus.Pending;
                    schedule.ScheduledFor = GetNextOccurrence(schedule.Recurrence, schedule.ScheduledFor, DateTime.UtcNow);
                }

                schedule.UpdatedAt = DateTime.UtcNow;
                await _scheduleRepository.UpdateAsync(schedule);
            }
            catch (Exception ex)
            {
                schedule.Status = NotificationScheduleStatus.Failed;
                schedule.Attempts += 1;
                schedule.LastError = ex.Message;
                schedule.UpdatedAt = DateTime.UtcNow;
                await _scheduleRepository.UpdateAsync(schedule);
            }
        }

        return processed;
    }

    private static DateTime GetNextOccurrence(NotificationRecurrence recurrence, DateTime baselineUtc, DateTime nowUtc)
    {
        var next = baselineUtc;

        switch (recurrence)
        {
            case NotificationRecurrence.Daily:
                do
                {
                    next = next.AddDays(1);
                } while (next <= nowUtc);
                return next;

            case NotificationRecurrence.Monthly:
                do
                {
                    next = next.AddMonths(1);
                } while (next <= nowUtc);
                return next;

            default:
                return baselineUtc;
        }
    }
}
