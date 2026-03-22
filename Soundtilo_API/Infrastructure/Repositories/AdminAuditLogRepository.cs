using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class AdminAuditLogRepository : IAdminAuditLogRepository
{
    private readonly SoundtiloDbContext _context;

    public AdminAuditLogRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task AddAsync(AdminAuditLog log)
    {
        _context.AdminAuditLogs.Add(log);
        await _context.SaveChangesAsync();
    }

    public async Task<IEnumerable<AdminAuditLog>> GetByAdminIdAsync(Guid adminId, int page = 1, int pageSize = 20)
    {
        var safePage = Math.Max(page, 1);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        return await _context.AdminAuditLogs
            .Where(l => l.AdminId == adminId)
            .OrderByDescending(l => l.CreatedAt)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .ToListAsync();
    }
}
