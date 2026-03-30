using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class NotificationDeliveryLogRepository : INotificationDeliveryLogRepository
{
    private readonly SoundtiloDbContext _context;

    public NotificationDeliveryLogRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task AddRangeAsync(IEnumerable<NotificationDeliveryLog> logs)
    {
        _context.NotificationDeliveryLogs.AddRange(logs);
        await _context.SaveChangesAsync();
    }

    public async Task<(IEnumerable<NotificationDeliveryLog> Logs, int Total)> GetPagedAsync(int page = 1, int pageSize = 20)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 200);

        var query = _context.NotificationDeliveryLogs.AsQueryable();
        var total = await query.CountAsync();

        var logs = await query
            .OrderByDescending(x => x.DeliveredAt)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .AsNoTracking()
            .ToListAsync();

        return (logs, total);
    }
}
