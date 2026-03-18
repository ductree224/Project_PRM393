using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Application.DTOs.Tracks;
using Application.Interfaces;

namespace Infrastructure.ExternalApis;

/// <summary>
/// Deezer API client - supplementary metadata for mainstream music.
/// Base URL: https://api.deezer.com/
/// No API key needed for basic endpoints.
/// Only 30s previews available (no full streaming).
/// </summary>
public class DeezerApiClient : IDeezerApiClient
{
    private readonly HttpClient _httpClient;
    private const string BaseUrl = "https://api.deezer.com";

    public DeezerApiClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    public async Task<IEnumerable<TrackDto>> SearchTracksAsync(string query, int limit = 20)
    {
        try
        {
            var url = $"{BaseUrl}/search?q={Uri.EscapeDataString(query)}&limit={limit}";
            var response = await _httpClient.GetFromJsonAsync<DeezerSearchResponse>(url, JsonOptions);
            if (response?.Data == null) return Enumerable.Empty<TrackDto>();

            return response.Data.Select(MapToTrackDto);
        }
        catch (Exception)
        {
            return Enumerable.Empty<TrackDto>();
        }
    }

    public async Task<IEnumerable<TrackDto>> GetChartTracksAsync(int limit = 20)
    {
        try
        {
            var url = $"{BaseUrl}/chart/0/tracks?limit={limit}";
            var response = await _httpClient.GetFromJsonAsync<DeezerSearchResponse>(url, JsonOptions);
            if (response?.Data == null) return Enumerable.Empty<TrackDto>();

            return response.Data.Select(MapToTrackDto);
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
            // Remove 'deezer_' prefix if present
            var id = trackId.StartsWith("deezer_") ? trackId.Substring(7) : trackId;
            var url = $"{BaseUrl}/track/{id}";
            var track = await _httpClient.GetFromJsonAsync<DeezerTrack>(url, JsonOptions);
            if (track == null) return null;

            return MapToTrackDto(track);
        }
        catch (Exception)
        {
            return null;
        }
    }

    private static TrackDto MapToTrackDto(DeezerTrack track)
    {
        return new TrackDto(
            ExternalId: $"deezer_{track.Id}",
            Source: "deezer",
            Title: track.Title ?? "Unknown",
            ArtistName: track.Artist?.Name ?? "Unknown Artist",
            AlbumName: track.Album?.Title,
            ArtworkUrl: track.Album?.CoverBig ?? track.Album?.CoverMedium,
            StreamUrl: null, // Deezer doesn't provide full streaming
            PreviewUrl: track.Preview,
            DurationSeconds: track.Duration ?? 0,
            Genre: null,
            Mood: null,
            PlayCount: track.Rank ?? 0
        );
    }

    private static JsonSerializerOptions JsonOptions => new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.SnakeCaseLower,
        PropertyNameCaseInsensitive = true
    };

    // Deezer API response models
    private class DeezerSearchResponse
    {
        [JsonPropertyName("data")]
        public List<DeezerTrack>? Data { get; set; }

        [JsonPropertyName("total")]
        public int? Total { get; set; }
    }

    private class DeezerTrack
    {
        [JsonPropertyName("id")]
        public long Id { get; set; }

        [JsonPropertyName("title")]
        public string? Title { get; set; }

        [JsonPropertyName("duration")]
        public int? Duration { get; set; }

        [JsonPropertyName("preview")]
        public string? Preview { get; set; }

        [JsonPropertyName("rank")]
        public long? Rank { get; set; }

        [JsonPropertyName("artist")]
        public DeezerArtist? Artist { get; set; }

        [JsonPropertyName("album")]
        public DeezerAlbum? Album { get; set; }
    }

    private class DeezerArtist
    {
        [JsonPropertyName("id")]
        public long Id { get; set; }

        [JsonPropertyName("name")]
        public string? Name { get; set; }

        [JsonPropertyName("picture_medium")]
        public string? PictureMedium { get; set; }
    }

    private class DeezerAlbum
    {
        [JsonPropertyName("id")]
        public long Id { get; set; }

        [JsonPropertyName("title")]
        public string? Title { get; set; }

        [JsonPropertyName("cover_medium")]
        public string? CoverMedium { get; set; }

        [JsonPropertyName("cover_big")]
        public string? CoverBig { get; set; }
    }
}
