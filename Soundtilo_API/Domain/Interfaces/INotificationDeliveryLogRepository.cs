using Domain.Entities;

namespace Domain.Interfaces;

public interface INotificationDeliveryLogRepository
{
    Task AddRangeAsync(IEnumerable<NotificationDeliveryLog> logs);
    Task<(IEnumerable<NotificationDeliveryLog> Logs, int Total)> GetPagedAsync(int page = 1, int pageSize = 20);
}
