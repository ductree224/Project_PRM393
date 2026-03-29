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

    public async Task<ListeningHistory> UpsertAsync(ListeningHistory history)
    {
        // Find all existing records for this user and track
        var existingRecords = await _context.ListeningHistories
            .Where(h => h.UserId == history.UserId && h.TrackExternalId == history.TrackExternalId)
            .OrderByDescending(h => h.ListenedAt)
            .ToListAsync();

        if (existingRecords.Any())
        {
            // Update the most recent one
            var latest = existingRecords.First();
            latest.ListenedAt = history.ListenedAt;
            latest.DurationListened = history.DurationListened;
            latest.Completed = history.Completed;

            // Remove any other duplicates (legacy data)
            if (existingRecords.Count > 1)
            {
                _context.ListeningHistories.RemoveRange(existingRecords.Skip(1));
            }

            await _context.SaveChangesAsync();
            return latest;
        }

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
