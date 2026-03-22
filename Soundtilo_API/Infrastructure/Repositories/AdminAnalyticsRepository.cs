using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class AdminAnalyticsRepository : IAdminAnalyticsRepository
{
    private readonly SoundtiloDbContext _context;

    public AdminAnalyticsRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<int> CountUsersByRoleAsync(string role)
    {
        return await _context.Users.CountAsync(u => u.Role == role);
    }

    public async Task<int> CountBannedUsersAsync()
    {
        return await _context.Users.CountAsync(u => u.IsBanned);
    }

    public async Task<int> CountNewUsersSinceAsync(DateTime since)
    {
        return await _context.Users.CountAsync(u => u.CreatedAt >= since);
    }

    public async Task<long> SumListeningTimeSecondsAsync()
    {
        return await _context.ListeningHistories
            .SumAsync(h => (long)h.DurationListened);
    }

    public async Task<int> CountCachedTracksAsync()
    {
        return await _context.CachedTracks.CountAsync();
    }

    public async Task<int> CountPlaylistsAsync()
    {
        return await _context.Playlists.CountAsync();
    }

    public async Task<IEnumerable<(string TrackExternalId, string Title, string Artist, int PlayCount)>> GetTopTracksAsync(int count)
    {
        var safeCount = Math.Clamp(count, 1, 100);

        var topTrackIds = await _context.ListeningHistories
            .GroupBy(h => h.TrackExternalId)
            .Select(g => new { TrackExternalId = g.Key, PlayCount = g.Count() })
            .OrderByDescending(x => x.PlayCount)
            .Take(safeCount)
            .ToListAsync();

        var externalIds = topTrackIds.Select(t => t.TrackExternalId).ToList();

        var cachedTracks = await _context.CachedTracks
            .Where(t => externalIds.Contains(t.ExternalId))
            .Select(t => new { t.ExternalId, t.Title, Artist = t.ArtistName })
            .ToListAsync();

        var trackLookup = cachedTracks.ToDictionary(t => t.ExternalId);

        return topTrackIds.Select(t =>
        {
            trackLookup.TryGetValue(t.TrackExternalId, out var cached);
            return (
                t.TrackExternalId,
                cached?.Title ?? t.TrackExternalId,
                cached?.Artist ?? "Unknown",
                t.PlayCount
            );
        });
    }

    public async Task<IEnumerable<(DateOnly Date, int NewUsers, int TotalListens, long TotalListeningSeconds)>> GetDailyStatsAsync(
        DateOnly from,
        DateOnly to)
    {
        var fromUtc = from.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);
        var toUtc = to.ToDateTime(TimeOnly.MaxValue, DateTimeKind.Utc);

        var newUsersPerDay = await _context.Users
            .Where(u => u.CreatedAt >= fromUtc && u.CreatedAt <= toUtc)
            .GroupBy(u => DateOnly.FromDateTime(u.CreatedAt))
            .Select(g => new { Date = g.Key, Count = g.Count() })
            .ToListAsync();

        var listensPerDay = await _context.ListeningHistories
            .Where(h => h.ListenedAt >= fromUtc && h.ListenedAt <= toUtc)
            .GroupBy(h => DateOnly.FromDateTime(h.ListenedAt))
            .Select(g => new
            {
                Date = g.Key,
                TotalListens = g.Count(),
                TotalSeconds = g.Sum(h => (long)h.DurationListened)
            })
            .ToListAsync();

        var listensLookup = listensPerDay.ToDictionary(x => x.Date);
        var usersLookup = newUsersPerDay.ToDictionary(x => x.Date);

        var allDates = newUsersPerDay.Select(x => x.Date)
            .Union(listensPerDay.Select(x => x.Date))
            .OrderBy(d => d);

        return allDates.Select(d =>
        {
            usersLookup.TryGetValue(d, out var u);
            listensLookup.TryGetValue(d, out var l);
            return (d, u?.Count ?? 0, l?.TotalListens ?? 0, l?.TotalSeconds ?? 0L);
        });
    }
}
