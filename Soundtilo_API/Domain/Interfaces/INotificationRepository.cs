using Domain.Entities;
using Domain.Enums;

namespace Domain.Interfaces;

public interface INotificationRepository
{
    Task<Notification> AddAsync(Notification notification);
    Task AddRangeAsync(IEnumerable<Notification> notifications);
    Task<Notification?> GetByIdAsync(Guid id);
    Task<(IEnumerable<Notification> Notifications, int Total)> GetByUserIdAsync(Guid userId, int page = 1, int pageSize = 20, bool? isRead = null);
    Task<int> GetUnreadCountAsync(Guid userId);
    Task<int> MarkAsReadAsync(Guid userId, Guid notificationId);
    Task<int> MarkAllAsReadAsync(Guid userId);
    Task<List<Guid>> GetAllUserIdsAsync();
    Task<List<Notification>> GetUnreadByUserIdAsync(Guid userId, int take = 50);
    Task<int> CleanupExpiredAsync(DateTime utcNow);
}
