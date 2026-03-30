using Application.DTOs.Notifications;

namespace Application.Interfaces;

public interface INotificationRealtimePublisher
{
    Task PublishToUserAsync(Guid userId, NotificationDto notification, CancellationToken cancellationToken = default);
    Task PublishToUsersAsync(IEnumerable<Guid> userIds, NotificationDto notification, CancellationToken cancellationToken = default);
}
