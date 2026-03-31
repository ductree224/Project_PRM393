using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class NotificationRepository : INotificationRepository
{
    private readonly SoundtiloDbContext _context;

    public NotificationRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<Notification> AddAsync(Notification notification)
    {
        _context.Notifications.Add(notification);
        await _context.SaveChangesAsync();
        return notification;
    }

    public async Task AddRangeAsync(IEnumerable<Notification> notifications)
    {
        _context.Notifications.AddRange(notifications);
        await _context.SaveChangesAsync();
    }

    public async Task<Notification?> GetByIdAsync(Guid id)
    {
        return await _context.Notifications.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task<(IEnumerable<Notification> Notifications, int Total)> GetByUserIdAsync(Guid userId, int page = 1, int pageSize = 20, bool? isRead = null)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var query = _context.Notifications.Where(x => x.UserId == userId);
        if (isRead.HasValue)
        {
            query = query.Where(x => x.IsRead == isRead.Value);
        }

        var total = await query.CountAsync();
        var notifications = await query
            .OrderByDescending(x => x.CreatedAt)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .AsNoTracking()
            .ToListAsync();

        return (notifications, total);
    }

    public Task<int> GetUnreadCountAsync(Guid userId)
    {
        return _context.Notifications.CountAsync(x => x.UserId == userId && !x.IsRead);
    }

    public async Task<int> MarkAsReadAsync(Guid userId, Guid notificationId)
    {
        return await _context.Notifications
            .Where(x => x.Id == notificationId && x.UserId == userId && !x.IsRead)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.IsRead, true)
                .SetProperty(x => x.ReadAt, DateTime.UtcNow));
    }

    public async Task<int> MarkAllAsReadAsync(Guid userId)
    {
        return await _context.Notifications
            .Where(x => x.UserId == userId && !x.IsRead)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.IsRead, true)
                .SetProperty(x => x.ReadAt, DateTime.UtcNow));
    }

    public async Task<List<Guid>> GetAllUserIdsAsync()
    {
        return await _context.Users.AsNoTracking().Select(x => x.Id).ToListAsync();
    }

    public async Task<List<Notification>> GetUnreadByUserIdAsync(Guid userId, int take = 50)
    {
        var safeTake = Math.Clamp(take, 1, 200);
        return await _context.Notifications
            .Where(x => x.UserId == userId && !x.IsRead)
            .OrderByDescending(x => x.CreatedAt)
            .Take(safeTake)
            .AsNoTracking()
            .ToListAsync();
    }

    public async Task<int> CleanupExpiredAsync(DateTime utcNow)
    {
        return await _context.Notifications
            .Where(x => x.ExpiresAt.HasValue && x.ExpiresAt <= utcNow)
            .ExecuteDeleteAsync();
    }

    public async Task<bool> HasRecentNotificationAsync(Guid userId, Domain.Enums.NotificationType type, TimeSpan within)
    {
        var cutoff = DateTime.UtcNow - within;
        return await _context.Notifications
            .AnyAsync(x => x.UserId == userId && x.Type == type && x.CreatedAt >= cutoff);
    }
}
