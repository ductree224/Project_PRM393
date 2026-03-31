using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class NotificationTemplateRepository : INotificationTemplateRepository
{
    private readonly SoundtiloDbContext _context;

    public NotificationTemplateRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public Task<NotificationTemplate?> GetByIdAsync(Guid id)
    {
        return _context.NotificationTemplates.FirstOrDefaultAsync(x => x.Id == id);
    }

    public async Task<(IEnumerable<NotificationTemplate> Templates, int Total)> GetPagedAsync(int page = 1, int pageSize = 20, bool? isActive = null)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var query = _context.NotificationTemplates.AsQueryable();
        if (isActive.HasValue)
        {
            query = query.Where(x => x.IsActive == isActive.Value);
        }

        var total = await query.CountAsync();
        var templates = await query
            .OrderByDescending(x => x.UpdatedAt)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .AsNoTracking()
            .ToListAsync();

        return (templates, total);
    }

    public async Task<NotificationTemplate> AddAsync(NotificationTemplate template)
    {
        _context.NotificationTemplates.Add(template);
        await _context.SaveChangesAsync();
        return template;
    }

    public async Task UpdateAsync(NotificationTemplate template)
    {
        _context.NotificationTemplates.Update(template);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(NotificationTemplate template)
    {
        _context.NotificationTemplates.Remove(template);
        await _context.SaveChangesAsync();
    }
}
