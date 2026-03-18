using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class HistoryRepository : IHistoryRepository
{
    private readonly SoundtiloDbContext _context;

    public HistoryRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<ListeningHistory>> GetByUserIdAsync(Guid userId, int page = 1, int pageSize = 20)
    {
        return await _context.ListeningHistories
            .Where(h => h.UserId == userId)
            .OrderByDescending(h => h.ListenedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task<ListeningHistory> AddAsync(ListeningHistory history)
    {
        _context.ListeningHistories.Add(history);
        await _context.SaveChangesAsync();
        return history;
    }

    public async Task<int> DeleteByIdsAsync(Guid userId, IReadOnlyCollection<Guid> historyIds)
    {
        if (historyIds.Count == 0)
        {
            return 0;
        }

        var rows = await _context.ListeningHistories
            .Where(h => h.UserId == userId && historyIds.Contains(h.Id))
            .ToListAsync();

        if (rows.Count == 0)
        {
            return 0;
        }

        _context.ListeningHistories.RemoveRange(rows);
        return await _context.SaveChangesAsync();
    }

    public async Task<int> GetTotalListensAsync(Guid userId)
    {
        return await _context.ListeningHistories.CountAsync(h => h.UserId == userId);
    }

    public async Task<int> GetTotalListeningTimeAsync(Guid userId)
    {
        return await _context.ListeningHistories
            .Where(h => h.UserId == userId)
            .SumAsync(h => h.DurationListened);
    }
}
