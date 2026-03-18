using System.Net.Http.Json;
using System.Text.Json;
using System.Text.Json.Serialization;
using Application.DTOs.Tracks;
using Application.Interfaces;

namespace Infrastructure.ExternalApis;

/// <summary>
/// Audius API client - primary music source with free full streaming.
/// Docs: https://docs.audius.org/
/// Base URL resolved dynamically from discovery endpoint.
/// No API key required — just pass app_name query param.
/// </summary>
public class AudiusApiClient : IAudiusApiClient
{
    private readonly HttpClient _httpClient;
    private string? _baseUrl;
    private const string AppName = "Soundtilo";
    private const string DiscoveryUrl = "https://api.audius.co";

    public AudiusApiClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
    }

    private async Task<string> GetBaseUrlAsync()
    {
        if (_baseUrl != null) return _baseUrl;

        try
        {
            var response = await _httpClient.GetFromJsonAsync<JsonElement>($"{DiscoveryUrl}/v1/tracks/trending?app_name={AppName}");
            _baseUrl = $"{DiscoveryUrl}/v1";
        }
        catch
        {
            _baseUrl = $"{DiscoveryUrl}/v1";
        }

        return _baseUrl;
    }

    public async Task<IEnumerable<TrackDto>> GetTrendingAsync(string? genre = null, string? time = null, int limit = 20)
    {
        try
        {
            var baseUrl = await GetBaseUrlAsync();
            var url = $"{baseUrl}/tracks/trending?app_name={AppName}&limit={limit}";
            if (!string.IsNullOrEmpty(genre)) url += $"&genre={Uri.EscapeDataString(genre)}";
            if (!string.IsNullOrEmpty(time)) url += $"&time={time}";

            var response = await _httpClient.GetFromJsonAsync<AudiusResponse<List<AudiusTrack>>>(url);
            if (response?.Data == null) return Enumerable.Empty<TrackDto>();

            return response.Data.Select(MapToTrackDto);
        }
        catch (Exception)
        {
            return Enumerable.Empty<TrackDto>();
        }
    }

    public async Task<IEnumerable<TrackDto>> SearchTracksAsync(string query, int limit = 20)
    {
        try
        {
            var baseUrl = await GetBaseUrlAsync();
            var url = $"{baseUrl}/tracks/search?query={Uri.EscapeDataString(query)}&app_name={AppName}&limit={limit}";

            var response = await _httpClient.GetFromJsonAsync<AudiusResponse<List<AudiusTrack>>>(url);
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
            var normalizedTrackId = NormalizeTrackId(trackId);
            var baseUrl = await GetBaseUrlAsync();
            var url = $"{baseUrl}/tracks/{normalizedTrackId}?app_name={AppName}";

            var response = await _httpClient.GetFromJsonAsync<AudiusResponse<AudiusTrack>>(url);
            if (response?.Data == null) return null;

            return MapToTrackDto(response.Data);
        }
        catch (Exception)
        {
            return null;
        }
    }

    public async Task<string?> GetStreamUrlAsync(string trackId)
    {
        var normalizedTrackId = NormalizeTrackId(trackId);
        var baseUrl = await GetBaseUrlAsync();
        return $"{baseUrl}/tracks/{normalizedTrackId}/stream?app_name={AppName}";
    }

    private static TrackDto MapToTrackDto(AudiusTrack track)
    {
        return new TrackDto(
            ExternalId: $"audius_{track.Id}",
            Source: "audius",
            Title: track.Title ?? "Unknown",
            ArtistName: track.User?.Name ?? "Unknown Artist",
            AlbumName: null,
            ArtworkUrl: track.Artwork?.PreferredUrl,
            StreamUrl: null, // Will be resolved on demand
            PreviewUrl: null,
            DurationSeconds: track.Duration ?? 0,
            Genre: track.Genre,
            Mood: track.Mood,
            PlayCount: track.PlayCount ?? 0
        );
    }

    private static string NormalizeTrackId(string trackId)
    {
        return trackId.StartsWith("audius_", StringComparison.OrdinalIgnoreCase)
            ? trackId[7..]
            : trackId;
    }

    // Audius API response models
    private class AudiusResponse<T>
    {
        public T? Data { get; set; }
    }

    private class AudiusTrack
    {
        public string? Id { get; set; }
        public string? Title { get; set; }
        public AudiusUser? User { get; set; }
        public AudiusArtwork? Artwork { get; set; }
        public int? Duration { get; set; }
        public string? Genre { get; set; }
        public string? Mood { get; set; }
        public long? PlayCount { get; set; }

        // JSON property aliases handled by System.Text.Json
        public string? Description { get; set; }
    }

    private class AudiusUser
    {
        public string? Name { get; set; }
        public string? Handle { get; set; }
    }

    private class AudiusArtwork
    {
        [JsonPropertyName("150x150")]
        public string? X150 { get; set; }

        [JsonPropertyName("150")]
        public string? X150Alt { get; set; }

        [JsonPropertyName("480x480")]
        public string? X480 { get; set; }

        [JsonPropertyName("480")]
        public string? X480Alt { get; set; }

        [JsonPropertyName("1000x1000")]
        public string? X1000 { get; set; }

        [JsonPropertyName("1000")]
        public string? X1000Alt { get; set; }

        public string? PreferredUrl => X480 ?? X480Alt ?? X1000 ?? X1000Alt ?? X150 ?? X150Alt;
    }
}
