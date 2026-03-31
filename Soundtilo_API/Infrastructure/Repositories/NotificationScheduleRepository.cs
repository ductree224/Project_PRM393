using Domain.Entities;
using Domain.Enums;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class NotificationScheduleRepository : INotificationScheduleRepository
{
    private readonly SoundtiloDbContext _context;

    public NotificationScheduleRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public Task<NotificationSchedule?> GetByIdAsync(Guid id)
    {
        return _context.NotificationSchedules.FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task<(IEnumerable<NotificationSchedule> Schedules, int Total)> GetPagedAsync(int page = 1, int pageSize = 20, NotificationScheduleStatus? status = null)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var query = _context.NotificationSchedules.AsQueryable();
        if (status.HasValue)
        {
            query = query.Where(x => x.Status == status.Value);
        }

        var total = await query.CountAsync();
        var schedules = await query
            .OrderByDescending(x => x.ScheduledFor)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .AsNoTracking()
            .ToListAsync();

        return (schedules, total);
    }

    public async Task<NotificationSchedule> AddAsync(NotificationSchedule schedule)
    {
        _context.NotificationSchedules.Add(schedule);
        await _context.SaveChangesAsync();
        return schedule;
    }

    public async Task UpdateAsync(NotificationSchedule schedule)
    {
        _context.NotificationSchedules.Update(schedule);
        await _context.SaveChangesAsync();
    }

    public async Task<bool> TryAcquireAsync(Guid scheduleId, DateTime utcNow)
    {
        var affected = await _context.NotificationSchedules
            .Where(x => x.Id == scheduleId && x.Status == NotificationScheduleStatus.Pending)
            .ExecuteUpdateAsync(setters => setters
                .SetProperty(x => x.Status, NotificationScheduleStatus.Processing)
                .SetProperty(x => x.UpdatedAt, utcNow));

        return affected == 1;
    }

    public async Task<List<NotificationSchedule>> GetDuePendingAsync(DateTime utcNow, int batchSize)
    {
        var safeBatchSize = Math.Clamp(batchSize, 1, 500);

        return await _context.NotificationSchedules
            .Where(x => x.Status == NotificationScheduleStatus.Pending && x.ScheduledFor <= utcNow)
            .OrderBy(x => x.ScheduledFor)
            .Take(safeBatchSize)
            .ToListAsync();
    }
}
