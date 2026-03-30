using Application.DTOs.Notifications;
using Application.Interfaces;
using Microsoft.AspNetCore.SignalR;
using Presentation.Hubs;

namespace Presentation.Realtime;

public class SignalRNotificationRealtimePublisher : INotificationRealtimePublisher
{
    private readonly IHubContext<NotificationHub> _hubContext;

    public SignalRNotificationRealtimePublisher(IHubContext<NotificationHub> hubContext)
    {
        _hubContext = hubContext;
    }

    public Task PublishToUserAsync(Guid userId, NotificationDto notification, CancellationToken cancellationToken = default)
    {
        return _hubContext.Clients.Group(NotificationHub.UserGroup(userId))
            .SendAsync("notification:created", notification, cancellationToken);
    }

    public async Task PublishToUsersAsync(IEnumerable<Guid> userIds, NotificationDto notification, CancellationToken cancellationToken = default)
    {
        foreach (var userId in userIds)
        {
            await PublishToUserAsync(userId, notification, cancellationToken);
        }
    }
}
