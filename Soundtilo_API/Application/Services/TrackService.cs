using Application.DTOs.Tracks;
using Application.Interfaces;
using Domain.Entities;
using Domain.Interfaces;

namespace Application.Services;

public class TrackService
{
    private readonly IAudiusApiClient _audiusApi;
    private readonly IDeezerApiClient _deezerApi;
    private readonly IJamendoApiClient _jamendoApi;
    private readonly ITrackCacheRepository _trackCache;

    public TrackService(
        IAudiusApiClient audiusApi,
        IDeezerApiClient deezerApi,
        IJamendoApiClient jamendoApi,
        ITrackCacheRepository trackCache)
    {
        _audiusApi = audiusApi;
        _deezerApi = deezerApi;
        _jamendoApi = jamendoApi;
        _trackCache = trackCache;
    }

    public async Task<TrackSearchResponse> SearchAsync(
        string query,
        string? source = null,
        int limit = 20,
        int offset = 0,
        bool cacheOnly = false,
        bool fallbackExternal = true)
    {
        var normalizedQuery = query.Trim();
        if (string.IsNullOrWhiteSpace(normalizedQuery))
            return new TrackSearchResponse(Enumerable.Empty<TrackDto>(), 0);

        var safeLimit = Math.Clamp(limit, 1, 50);
        var cacheTracks = (await _trackCache.SearchAsync(normalizedQuery, source, safeLimit, offset))
            .Select(MapCachedTrackToDto)
            .ToList();

        if (cacheOnly || !fallbackExternal || cacheTracks.Count >= safeLimit)
        {
            return new TrackSearchResponse(cacheTracks, cacheTracks.Count);
        }

        var tracks = new List<TrackDto>(cacheTracks);
        var remainingSlots = safeLimit - tracks.Count;
        if (remainingSlots <= 0)
        {
            return new TrackSearchResponse(tracks, tracks.Count);
        }

        var externalTracks = new List<TrackDto>();

        if (source == null || source == "audius")
        {
            var audiusTracks = await _audiusApi.SearchTracksAsync(normalizedQuery, remainingSlots);
            externalTracks.AddRange(audiusTracks);
        }

        if (source == null || source == "deezer")
        {
            var deezerTracks = await _deezerApi.SearchTracksAsync(normalizedQuery, remainingSlots);
            externalTracks.AddRange(deezerTracks);
        }

        if (source == null || source == "jamendo")
        {
            var jamendoTracks = await _jamendoApi.SearchTracksAsync(normalizedQuery, remainingSlots);
            externalTracks.AddRange(jamendoTracks);
        }

        var seenExternalIds = new HashSet<string>(tracks.Select(t => t.ExternalId), StringComparer.OrdinalIgnoreCase);
        foreach (var externalTrack in externalTracks)
        {
            if (seenExternalIds.Add(externalTrack.ExternalId))
            {
                tracks.Add(externalTrack);
            }

            if (tracks.Count >= safeLimit)
            {
                break;
            }
        }

        // Cache only tracks fetched from external providers
        var cachedEntities = externalTracks.Select(t => new CachedTrack
        {
            Id = Guid.NewGuid(),
            ExternalId = t.ExternalId,
            Source = t.Source,
            Title = t.Title,
            ArtistName = t.ArtistName,
            AlbumName = t.AlbumName,
            ArtworkUrl = t.ArtworkUrl,
            StreamUrl = t.StreamUrl,
            PreviewUrl = t.PreviewUrl,
            DurationSeconds = t.DurationSeconds,
            Genre = t.Genre,
            Mood = t.Mood,
            PlayCount = t.PlayCount,
            CachedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddHours(24)
        });

        if (cachedEntities.Any())
        {
            await _trackCache.UpsertManyAsync(cachedEntities);
        }

        return new TrackSearchResponse(tracks, tracks.Count);
    }

    private static TrackDto MapCachedTrackToDto(CachedTrack cached)
    {
        return new TrackDto(
            ExternalId: cached.ExternalId,
            Source: cached.Source,
            Title: cached.Title,
            ArtistName: cached.ArtistName,
            AlbumName: cached.AlbumName,
            ArtworkUrl: cached.ArtworkUrl,
            StreamUrl: cached.StreamUrl,
            PreviewUrl: cached.PreviewUrl,
            DurationSeconds: cached.DurationSeconds,
            Genre: cached.Genre,
            Mood: cached.Mood,
            PlayCount: cached.PlayCount
        );
    }

    public async Task<TrendingResponse> GetTrendingAsync(string? genre = null, string? time = null, int limit = 20, int offset = 0)
    {
        // Serve from DB cache first (any page) — avoids hitting external APIs if data is fresh
        var cached = (await _trackCache.GetCachedTrendingAsync(genre, limit, offset)).ToList();
        if (cached.Any())
            return new TrendingResponse(cached.Select(MapCachedTrackToDto).ToList());

        // Cache miss — only external API fallback is available for page 0
        if (offset > 0)
            return new TrendingResponse([]);

        // Page 0 cache miss: fetch all external APIs in parallel to minimize latency
        var fetchLimit = Math.Max(limit, 50);

        var audiusTask = _audiusApi.GetTrendingAsync(genre, time, fetchLimit);
        var deezerTask = _deezerApi.GetChartTracksAsync(fetchLimit);
        var jamendoTask = _jamendoApi.GetPopularTracksAsync(fetchLimit);
        await Task.WhenAll(audiusTask, deezerTask, jamendoTask);

        var tracks = new List<TrackDto>();
        tracks.AddRange(audiusTask.Result);
        tracks.AddRange(deezerTask.Result);
        tracks.AddRange(jamendoTask.Result);

        // Deduplicate by ExternalId
        var seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
        var uniqueTracks = new List<TrackDto>();
        foreach (var t in tracks)
        {
            if (seen.Add(t.ExternalId))
                uniqueTracks.Add(t);
        }

        // Cache all unique tracks
        var cachedEntities = uniqueTracks.Select(t => new CachedTrack
        {
            Id = Guid.NewGuid(),
            ExternalId = t.ExternalId,
            Source = t.Source,
            Title = t.Title,
            ArtistName = t.ArtistName,
            AlbumName = t.AlbumName,
            ArtworkUrl = t.ArtworkUrl,
            StreamUrl = t.StreamUrl,
            PreviewUrl = t.PreviewUrl,
            DurationSeconds = t.DurationSeconds,
            Genre = t.Genre,
            Mood = t.Mood,
            PlayCount = t.PlayCount,
            CachedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddHours(24)
        });

        await _trackCache.UpsertManyAsync(cachedEntities);

        // Return only the requested page
        var page = uniqueTracks.Take(limit).ToList();
        return new TrendingResponse(page);
    }

    public async Task<TrackDto?> GetTrackAsync(string externalId, string source = "audius")
    {
        // Check cache first
        var cached = await _trackCache.GetByExternalIdAsync(externalId);
        if (cached != null && cached.ExpiresAt > DateTime.UtcNow)
        {
            return new TrackDto(
                ExternalId: cached.ExternalId,
                Source: cached.Source,
                Title: cached.Title,
                ArtistName: cached.ArtistName,
                AlbumName: cached.AlbumName,
                ArtworkUrl: cached.ArtworkUrl,
                StreamUrl: cached.StreamUrl,
                PreviewUrl: cached.PreviewUrl,
                DurationSeconds: cached.DurationSeconds,
                Genre: cached.Genre,
                Mood: cached.Mood,
                PlayCount: cached.PlayCount
            );
        }

        // Fetch from API
        TrackDto? track = source switch
        {
            "audius" => await _audiusApi.GetTrackAsync(externalId),
            "deezer" => await _deezerApi.GetTrackAsync(externalId),
            "jamendo" => await _jamendoApi.GetTrackAsync(externalId),
            _ => null
        };

        if (track != null)
        {
            await _trackCache.UpsertAsync(new CachedTrack
            {
                Id = Guid.NewGuid(),
                ExternalId = track.ExternalId,
                Source = track.Source,
                Title = track.Title,
                ArtistName = track.ArtistName,
                AlbumName = track.AlbumName,
                ArtworkUrl = track.ArtworkUrl,
                StreamUrl = track.StreamUrl,
                PreviewUrl = track.PreviewUrl,
                DurationSeconds = track.DurationSeconds,
                Genre = track.Genre,
                Mood = track.Mood,
                PlayCount = track.PlayCount,
                CachedAt = DateTime.UtcNow,
                ExpiresAt = DateTime.UtcNow.AddHours(24)
            });
        }

        return track;
    }

    public async Task<string?> GetStreamUrlAsync(string trackId)
    {
        if (string.IsNullOrWhiteSpace(trackId))
            return null;

        var source = ExtractSource(trackId);

        switch (source)
        {
            case "audius":
                return await _audiusApi.GetStreamUrlAsync(trackId);

            case "jamendo":
                {
                    var cachedJamendo = await _trackCache.GetByExternalIdAsync(trackId);
                    return cachedJamendo?.StreamUrl ?? await _jamendoApi.GetStreamUrlAsync(trackId);
                }

            case "deezer":
                {
                    var cachedDeezer = await _trackCache.GetByExternalIdAsync(trackId);
                    if (!string.IsNullOrWhiteSpace(cachedDeezer?.PreviewUrl))
                        return cachedDeezer!.PreviewUrl;

                    var deezerTrack = await _deezerApi.GetTrackAsync(trackId);
                    return deezerTrack?.PreviewUrl;
                }

            default:
                {
                    var cached = await _trackCache.GetByExternalIdAsync(trackId);
                    if (!string.IsNullOrWhiteSpace(cached?.StreamUrl))
                        return cached!.StreamUrl;
                    if (!string.IsNullOrWhiteSpace(cached?.PreviewUrl))
                        return cached!.PreviewUrl;

                    var audiusUrl = await _audiusApi.GetStreamUrlAsync(trackId);
                    if (!string.IsNullOrWhiteSpace(audiusUrl))
                        return audiusUrl;

                    return await _jamendoApi.GetStreamUrlAsync(trackId);
                }
        }
    }

    private static string? ExtractSource(string externalId)
    {
        var separatorIndex = externalId.IndexOf('_');
        if (separatorIndex <= 0)
            return null;

        return externalId[..separatorIndex].ToLowerInvariant();
    }

    /// <summary>
    /// Browse tracks by tag/genre via Jamendo.
    /// </summary>
    public async Task<TrackSearchResponse> GetByTagAsync(string tag, int limit = 20)
    {
        var tracks = (await _jamendoApi.GetTracksByTagAsync(tag, limit)).ToList();

        // Cache
        var cachedEntities = tracks.Select(t => new CachedTrack
        {
            Id = Guid.NewGuid(),
            ExternalId = t.ExternalId,
            Source = t.Source,
            Title = t.Title,
            ArtistName = t.ArtistName,
            AlbumName = t.AlbumName,
            ArtworkUrl = t.ArtworkUrl,
            StreamUrl = t.StreamUrl,
            PreviewUrl = t.PreviewUrl,
            DurationSeconds = t.DurationSeconds,
            Genre = t.Genre,
            Mood = t.Mood,
            PlayCount = t.PlayCount,
            CachedAt = DateTime.UtcNow,
            ExpiresAt = DateTime.UtcNow.AddHours(24)
        });

        await _trackCache.UpsertManyAsync(cachedEntities);

        return new TrackSearchResponse(tracks, tracks.Count);
    }
}
