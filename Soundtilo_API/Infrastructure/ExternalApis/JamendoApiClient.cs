using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Application.DTOs.Tracks;
using Application.Interfaces;
using Microsoft.Extensions.Configuration;

namespace Infrastructure.ExternalApis;

/// <summary>
/// Jamendo API client - CC-licensed music with full free streaming.
/// Base URL: https://api.jamendo.com/v3.0/
/// Requires a free client_id from https://developer.jamendo.com/
/// Supports: search, popular/trending, tag browsing, full MP3 streaming.
/// </summary>
public class JamendoApiClient : IJamendoApiClient
{
    private readonly HttpClient _httpClient;
    private readonly string _clientId;
    private const string BaseUrl = "https://api.jamendo.com/v3.0";

    public JamendoApiClient(HttpClient httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _clientId = configuration["Jamendo:ClientId"]
            ?? throw new InvalidOperationException("Jamendo:ClientId is not configured in appsettings.");
    }

    public async Task<IEnumerable<TrackDto>> SearchTracksAsync(string query, int limit = 20)
    {
        try
        {
            var url = $"{BaseUrl}/tracks/?client_id={_clientId}&format=json&limit={limit}" +
                      $"&search={Uri.EscapeDataString(query)}&include=musicinfo";
            var response = await _httpClient.GetFromJsonAsync<JamendoResponse>(url, JsonOptions);
            if (response?.Results == null) return Enumerable.Empty<TrackDto>();

            return response.Results.Select(MapToTrackDto);
        }
        catch (Exception)
        {
            return Enumerable.Empty<TrackDto>();
        }
    }

    public async Task<IEnumerable<TrackDto>> GetPopularTracksAsync(int limit = 20)
    {
        try
        {
            var url = $"{BaseUrl}/tracks/?client_id={_clientId}&format=json&limit={limit}" +
                      "&order=popularity_total&include=musicinfo";
            var response = await _httpClient.GetFromJsonAsync<JamendoResponse>(url, JsonOptions);
            if (response?.Results == null) return Enumerable.Empty<TrackDto>();

            return response.Results.Select(MapToTrackDto);
        }
        catch (Exception)
        {
            return Enumerable.Empty<TrackDto>();
        }
    }

    public async Task<IEnumerable<TrackDto>> GetTracksByTagAsync(string tag, int limit = 20)
    {
        try
        {
            var url = $"{BaseUrl}/tracks/?client_id={_clientId}&format=json&limit={limit}" +
                      $"&tags={Uri.EscapeDataString(tag)}&order=popularity_total&include=musicinfo";
            var response = await _httpClient.GetFromJsonAsync<JamendoResponse>(url, JsonOptions);
            if (response?.Results == null) return Enumerable.Empty<TrackDto>();

            return response.Results.Select(MapToTrackDto);
        }
        catch (Exception)
        {
            return Enumerable.Empty<TrackDto>();
        }
    }

    public async Task<TrackDto?> GetTrackAsync(string trackId)
    {
        try
        {
            // Remove 'jamendo_' prefix if present
            var id = trackId.StartsWith("jamendo_") ? trackId.Substring(8) : trackId;
            var url = $"{BaseUrl}/tracks/?client_id={_clientId}&format=json&id={id}&include=musicinfo";
            var response = await _httpClient.GetFromJsonAsync<JamendoResponse>(url, JsonOptions);
            var track = response?.Results?.FirstOrDefault();
            if (track == null) return null;

            return MapToTrackDto(track);
        }
        catch (Exception)
        {
            return null;
        }
    }

    public Task<string?> GetStreamUrlAsync(string trackId)
    {
        // Remove 'jamendo_' prefix if present
        var id = trackId.StartsWith("jamendo_") ? trackId.Substring(8) : trackId;

        // Jamendo provides direct MP3 streaming via audio/audiodownload fields.
        // Construct the standard streaming URL.
        var streamUrl = $"https://mp3l.jamendo.com/?trackid={id}&format=mp31";
        return Task.FromResult<string?>(streamUrl);
    }

    private static TrackDto MapToTrackDto(JamendoTrack track)
    {
        // Extract genre from musicinfo tags if available
        string? genre = null;
        if (track.MusicInfo?.Tags?.Genres != null && track.MusicInfo.Tags.Genres.Count > 0)
            genre = string.Join(", ", track.MusicInfo.Tags.Genres);

        // Extract mood from musicinfo
        string? mood = null;
        if (track.MusicInfo?.Tags?.Vartags != null && track.MusicInfo.Tags.Vartags.Count > 0)
            mood = string.Join(", ", track.MusicInfo.Tags.Vartags.Take(3));

        return new TrackDto(
            ExternalId: $"jamendo_{track.Id}",
            Source: "jamendo",
            Title: track.Name ?? "Unknown",
            ArtistName: track.ArtistName ?? "Unknown Artist",
            AlbumName: track.AlbumName,
            ArtworkUrl: track.AlbumImage ?? track.Image,
            StreamUrl: track.Audio, // Jamendo provides FULL streaming
            PreviewUrl: track.AudioDownload,
            DurationSeconds: track.Duration ?? 0,
            Genre: genre,
            Mood: mood,
            PlayCount: track.Stats?.ListenedAll ?? 0
        );
    }

    private static JsonSerializerOptions JsonOptions => new()
    {
        PropertyNameCaseInsensitive = true
    };

    // ── Jamendo API response models ──

    private class JamendoResponse
    {
        [JsonPropertyName("headers")]
        public JamendoHeaders? Headers { get; set; }

        [JsonPropertyName("results")]
        public List<JamendoTrack>? Results { get; set; }
    }

    private class JamendoHeaders
    {
        [JsonPropertyName("status")]
        public string? Status { get; set; }

        [JsonPropertyName("results_count")]
        public int ResultsCount { get; set; }
    }

    private class JamendoTrack
    {
        [JsonPropertyName("id")]
        public string? Id { get; set; }

        [JsonPropertyName("name")]
        public string? Name { get; set; }

        [JsonPropertyName("duration")]
        public int? Duration { get; set; }

        [JsonPropertyName("artist_id")]
        public string? ArtistId { get; set; }

        [JsonPropertyName("artist_name")]
        public string? ArtistName { get; set; }

        [JsonPropertyName("album_name")]
        public string? AlbumName { get; set; }

        [JsonPropertyName("album_id")]
        public string? AlbumId { get; set; }

        [JsonPropertyName("album_image")]
        public string? AlbumImage { get; set; }

        [JsonPropertyName("image")]
        public string? Image { get; set; }

        [JsonPropertyName("audio")]
        public string? Audio { get; set; }

        [JsonPropertyName("audiodownload")]
        public string? AudioDownload { get; set; }

        [JsonPropertyName("position")]
        public int? Position { get; set; }

        [JsonPropertyName("releasedate")]
        public string? ReleaseDate { get; set; }

        [JsonPropertyName("musicinfo")]
        public JamendoMusicInfo? MusicInfo { get; set; }

        [JsonPropertyName("stats")]
        public JamendoStats? Stats { get; set; }
    }

    private class JamendoMusicInfo
    {
        [JsonPropertyName("tags")]
        public JamendoTags? Tags { get; set; }
    }

    private class JamendoTags
    {
        [JsonPropertyName("genres")]
        public List<string>? Genres { get; set; }

        [JsonPropertyName("instruments")]
        public List<string>? Instruments { get; set; }

        [JsonPropertyName("vartags")]
        public List<string>? Vartags { get; set; }
    }

    private class JamendoStats
    {
        [JsonPropertyName("rate")]
        public JamendoRate? Rate { get; set; }

        [JsonPropertyName("listened_all")]
        public long ListenedAll { get; set; }
    }

    private class JamendoRate
    {
        [JsonPropertyName("average")]
        public double? Average { get; set; }
    }
}
