using Domain.Entities;
using Domain.Enums;

namespace Domain.Interfaces;

public interface INotificationScheduleRepository
{
    Task<NotificationSchedule?> GetByIdAsync(Guid id);
    Task<(IEnumerable<NotificationSchedule> Schedules, int Total)> GetPagedAsync(int page = 1, int pageSize = 20, NotificationScheduleStatus? status = null);
    Task<NotificationSchedule> AddAsync(NotificationSchedule schedule);
    Task UpdateAsync(NotificationSchedule schedule);
    Task<bool> TryAcquireAsync(Guid scheduleId, DateTime utcNow);
    Task<List<NotificationSchedule>> GetDuePendingAsync(DateTime utcNow, int batchSize);
}
