using Domain.Entities;

namespace Domain.Interfaces;

public interface INotificationTemplateRepository
{
    Task<NotificationTemplate?> GetByIdAsync(Guid id);
    Task<(IEnumerable<NotificationTemplate> Templates, int Total)> GetPagedAsync(int page = 1, int pageSize = 20, bool? isActive = null);
    Task<NotificationTemplate> AddAsync(NotificationTemplate template);
    Task UpdateAsync(NotificationTemplate template);
    Task DeleteAsync(NotificationTemplate template);
}
