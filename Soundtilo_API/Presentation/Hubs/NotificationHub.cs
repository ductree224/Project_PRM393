using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;

namespace Presentation.Hubs;

[Authorize]
public class NotificationHub : Hub
{
    public override async Task OnConnectedAsync()
    {
        var userId = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? Context.User?.FindFirstValue("sub");

        if (Guid.TryParse(userId, out var parsedUserId))
        {
            await Groups.AddToGroupAsync(Context.ConnectionId, UserGroup(parsedUserId));
        }

        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var userId = Context.User?.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? Context.User?.FindFirstValue("sub");

        if (Guid.TryParse(userId, out var parsedUserId))
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, UserGroup(parsedUserId));
        }

        await base.OnDisconnectedAsync(exception);
    }

    public static string UserGroup(Guid userId) => $"user:{userId:D}";
}
