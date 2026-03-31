using Domain.Entities;
using Domain.Interfaces;
using Domain.Enums;
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
        return await _context.CachedTracks.FirstOrDefaultAsync(t => EF.Functions.ILike(t.ExternalId, externalId));
    }

    public async Task<IEnumerable<CachedTrack>> GetManyByExternalIdsAsync(IEnumerable<string> externalIds)
    {
        return await _context.CachedTracks
            .Where(t => externalIds.Contains(t.ExternalId))
            .ToListAsync();
    }

    public async Task<IEnumerable<CachedTrack>> SearchAsync(string query, string? source = null, int limit = 20, int offset = 0)
    {
        var normalizedQuery = query.Trim();
        if (string.IsNullOrWhiteSpace(normalizedQuery))
            return Enumerable.Empty<CachedTrack>();

        var safeLimit = Math.Clamp(limit, 1, 50);
        var safeOffset = Math.Max(offset, 0);

        var tracksQuery = _context.CachedTracks
            .Where(t => t.ExpiresAt > DateTime.UtcNow && t.Status == TrackStatus.Active)
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

    public async Task<IEnumerable<CachedTrack>> GetCachedTrendingAsync(string? genre = null, int limit = 20, int offset = 0)
    {
        var safeLimit = Math.Clamp(limit, 1, 50);
        var safeOffset = Math.Max(offset, 0);

        var query = _context.CachedTracks
            .Where(t => t.ExpiresAt > DateTime.UtcNow && t.Status == TrackStatus.Active);

        if (!string.IsNullOrWhiteSpace(genre))
        {
            query = query.Where(t => t.Genre != null && EF.Functions.ILike(t.Genre, $"%{genre}%"));
        }

        return await query
            .OrderByDescending(t => t.PlayCount)
            .ThenByDescending(t => t.CachedAt)
            .Skip(safeOffset)
            .Take(safeLimit)
            .ToListAsync();
    }

    public async Task<CachedTrack> UpsertAsync(CachedTrack track)
    {
        if (track.Id == Guid.Empty)
            track.Id = Guid.NewGuid();

        track.CachedAt = DateTime.UtcNow;
        track.ExpiresAt = DateTime.UtcNow.AddHours(24);

        await _context.Database.ExecuteSqlInterpolatedAsync(
            $"""
            INSERT INTO cached_tracks (id, album_name, artist_name, artwork_url, cached_at, duration_seconds, expires_at, external_data, external_id, genre, mood, play_count, preview_url, source, stream_url, title)
            VALUES ({track.Id}, {track.AlbumName}, {track.ArtistName}, {track.ArtworkUrl}, {track.CachedAt}, {track.DurationSeconds}, {track.ExpiresAt}, {track.ExternalData}, {track.ExternalId}, {track.Genre}, {track.Mood}, {track.PlayCount}, {track.PreviewUrl}, {track.Source}, {track.StreamUrl}, {track.Title})
            ON CONFLICT (external_id) DO UPDATE SET
                album_name = EXCLUDED.album_name, artist_name = EXCLUDED.artist_name,
                artwork_url = EXCLUDED.artwork_url, cached_at = EXCLUDED.cached_at,
                duration_seconds = EXCLUDED.duration_seconds, expires_at = EXCLUDED.expires_at,
                external_data = EXCLUDED.external_data, genre = EXCLUDED.genre,
                mood = EXCLUDED.mood, play_count = EXCLUDED.play_count,
                preview_url = EXCLUDED.preview_url, source = EXCLUDED.source,
                stream_url = EXCLUDED.stream_url, title = EXCLUDED.title
            """);

        return track;
    }

    public async Task UpsertManyAsync(IEnumerable<CachedTrack> tracks)
    {
        // Deduplicate input by ExternalId (last wins)
        var uniqueTracks = new Dictionary<string, CachedTrack>(StringComparer.OrdinalIgnoreCase);
        foreach (var track in tracks)
            uniqueTracks[track.ExternalId] = track;

        if (uniqueTracks.Count == 0) return;

        var now = DateTime.UtcNow;
        foreach (var track in uniqueTracks.Values)
        {
            if (track.Id == Guid.Empty)
                track.Id = Guid.NewGuid();

            track.CachedAt = now;
            track.ExpiresAt = now.AddHours(24);

            await _context.Database.ExecuteSqlInterpolatedAsync(
                $"""
                INSERT INTO cached_tracks (id, album_name, artist_name, artwork_url, cached_at, duration_seconds, expires_at, external_data, external_id, genre, mood, play_count, preview_url, source, stream_url, title)
                VALUES ({track.Id}, {track.AlbumName}, {track.ArtistName}, {track.ArtworkUrl}, {track.CachedAt}, {track.DurationSeconds}, {track.ExpiresAt}, {track.ExternalData}, {track.ExternalId}, {track.Genre}, {track.Mood}, {track.PlayCount}, {track.PreviewUrl}, {track.Source}, {track.StreamUrl}, {track.Title})
                ON CONFLICT (external_id) DO UPDATE SET
                    album_name = EXCLUDED.album_name, artist_name = EXCLUDED.artist_name,
                    artwork_url = EXCLUDED.artwork_url, cached_at = EXCLUDED.cached_at,
                    duration_seconds = EXCLUDED.duration_seconds, expires_at = EXCLUDED.expires_at,
                    external_data = EXCLUDED.external_data, genre = EXCLUDED.genre,
                    mood = EXCLUDED.mood, play_count = EXCLUDED.play_count,
                    preview_url = EXCLUDED.preview_url, source = EXCLUDED.source,
                    stream_url = EXCLUDED.stream_url, title = EXCLUDED.title
                """);
        }
    }

    public async Task CleanExpiredAsync()
    {
        var expired = _context.CachedTracks.Where(t => t.ExpiresAt <= DateTime.UtcNow);
        _context.CachedTracks.RemoveRange(expired);
        await _context.SaveChangesAsync();
    }

    public async Task<IEnumerable<CachedTrack>> ListAsync(TrackStatus? status = null, string? query = null, int limit = 50, int offset = 0)
    {
        var safeLimit = Math.Clamp(limit, 1, 100);
        var safeOffset = Math.Max(offset, 0);

        var tracksQuery = _context.CachedTracks.AsQueryable();

        if (status.HasValue)
        {
            tracksQuery = tracksQuery.Where(t => t.Status == status.Value);
        }

        if (!string.IsNullOrWhiteSpace(query))
        {
            var normalized = query.Trim();
            tracksQuery = tracksQuery.Where(t => EF.Functions.ILike(t.Title, $"%{normalized}%") || EF.Functions.ILike(t.ArtistName, $"%{normalized}%"));
        }

        return await tracksQuery
            .OrderByDescending(t => t.CachedAt)
            .Skip(safeOffset)
            .Take(safeLimit)
            .ToListAsync();
    }

    public async Task UpdateStatusesAsync(IEnumerable<string> externalIds, TrackStatus status)
    {
        var tracks = await _context.CachedTracks
            .Where(t => externalIds.Contains(t.ExternalId))
            .ToListAsync();

        foreach (var track in tracks)
        {
            track.Status = status;
        }

        await _context.SaveChangesAsync();
    }
}
