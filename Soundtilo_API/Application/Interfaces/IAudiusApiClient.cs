using Application.DTOs.Tracks;

namespace Application.Interfaces;

/// <summary>
/// Interface for Audius API client - primary music source (free full streaming)
/// Base URL: https://api.audius.co/v1/
/// </summary>
public interface IAudiusApiClient
{
    Task<IEnumerable<TrackDto>> GetTrendingAsync(string? genre = null, string? time = null, int limit = 20);
    Task<IEnumerable<TrackDto>> SearchTracksAsync(string query, int limit = 20);
    Task<TrackDto?> GetTrackAsync(string trackId);
    Task<string?> GetStreamUrlAsync(string trackId);
}
