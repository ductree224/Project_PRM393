using System.Net.Http.Json;
using System.Text.Json.Serialization;
using Application.Interfaces;

namespace Infrastructure.ExternalApis;

/// <summary>
/// Lyrics API client using lyrics.ovh - completely free, no API key needed.
/// GET https://api.lyrics.ovh/v1/{artist}/{title}
/// </summary>
public class LyricsApiClient : ILyricsApiClient
{
    private readonly HttpClient _httpClient;
    private const string BaseUrl = "https://api.lyrics.ovh/v1";

    public LyricsApiClient(HttpClient httpClient)
    {
        _httpClient = httpClient;
        _httpClient.Timeout = TimeSpan.FromSeconds(10);
    }

    public async Task<string?> GetLyricsAsync(string artist, string title)
    {
        try
        {
            var url = $"{BaseUrl}/{Uri.EscapeDataString(artist)}/{Uri.EscapeDataString(title)}";
            var response = await _httpClient.GetFromJsonAsync<LyricsResponse>(url);
            return response?.Lyrics;
        }
        catch (Exception)
        {
            return null;
        }
    }

    private class LyricsResponse
    {
        [JsonPropertyName("lyrics")]
        public string? Lyrics { get; set; }
    }
}
