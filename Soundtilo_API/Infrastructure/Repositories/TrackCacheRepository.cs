using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class TrackCacheRepository : ITrackCacheRepository
{
    private readonly SoundtiloDbContext _context;

    public TrackCacheRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<CachedTrack?> GetByExternalIdAsync(string externalId)
    {
        return await _context.CachedTracks.FirstOrDefaultAsync(t => t.ExternalId == externalId);
    }

    public async Task<IEnumerable<CachedTrack>> SearchAsync(string query, string? source = null, int limit = 20, int offset = 0)
    {
        var normalizedQuery = query.Trim();
        if (string.IsNullOrWhiteSpace(normalizedQuery))
            return Enumerable.Empty<CachedTrack>();

        var safeLimit = Math.Clamp(limit, 1, 50);
        var safeOffset = Math.Max(offset, 0);

        var tracksQuery = _context.CachedTracks
            .Where(t => t.ExpiresAt > DateTime.UtcNow)
            .Where(t => EF.Functions.ILike(t.Title, $"%{normalizedQuery}%") || EF.Functions.ILike(t.ArtistName, $"%{normalizedQuery}%"));

        if (!string.IsNullOrWhiteSpace(source))
        {
            tracksQuery = tracksQuery.Where(t => t.Source == source);
        }

        return await tracksQuery
            .OrderByDescending(t => EF.Functions.ILike(t.Title, $"{normalizedQuery}%"))
            .ThenByDescending(t => EF.Functions.ILike(t.ArtistName, $"{normalizedQuery}%"))
            .ThenByDescending(t => t.PlayCount)
            .ThenByDescending(t => t.CachedAt)
            .Skip(safeOffset)
            .Take(safeLimit)
            .ToListAsync();
    }

    public async Task<CachedTrack> UpsertAsync(CachedTrack track)
    {
        var existing = await _context.CachedTracks.FirstOrDefaultAsync(t => t.ExternalId == track.ExternalId);
        if (existing != null)
        {
            existing.Title = track.Title;
            existing.ArtistName = track.ArtistName;
            existing.AlbumName = track.AlbumName;
            existing.ArtworkUrl = track.ArtworkUrl;
            existing.StreamUrl = track.StreamUrl;
            existing.PreviewUrl = track.PreviewUrl;
            existing.DurationSeconds = track.DurationSeconds;
            existing.Genre = track.Genre;
            existing.Mood = track.Mood;
            existing.PlayCount = track.PlayCount;
            existing.ExternalData = track.ExternalData;
            existing.CachedAt = DateTime.UtcNow;
            existing.ExpiresAt = DateTime.UtcNow.AddHours(24);
        }
        else
        {
            _context.CachedTracks.Add(track);
        }

        await _context.SaveChangesAsync();
        return existing ?? track;
    }

    public async Task UpsertManyAsync(IEnumerable<CachedTrack> tracks)
    {
        foreach (var track in tracks)
        {
            var existing = await _context.CachedTracks.FirstOrDefaultAsync(t => t.ExternalId == track.ExternalId);
            if (existing != null)
            {
                existing.Title = track.Title;
                existing.ArtistName = track.ArtistName;
                existing.AlbumName = track.AlbumName;
                existing.ArtworkUrl = track.ArtworkUrl;
                existing.StreamUrl = track.StreamUrl;
                existing.PreviewUrl = track.PreviewUrl;
                existing.DurationSeconds = track.DurationSeconds;
                existing.Genre = track.Genre;
                existing.Mood = track.Mood;
                existing.PlayCount = track.PlayCount;
                existing.ExternalData = track.ExternalData;
                existing.CachedAt = DateTime.UtcNow;
                existing.ExpiresAt = DateTime.UtcNow.AddHours(24);
            }
            else
            {
                _context.CachedTracks.Add(track);
            }
        }

        await _context.SaveChangesAsync();
    }

    public async Task CleanExpiredAsync()
    {
        var expired = _context.CachedTracks.Where(t => t.ExpiresAt <= DateTime.UtcNow);
        _context.CachedTracks.RemoveRange(expired);
        await _context.SaveChangesAsync();
    }
}
