using Application.DTOs.Tracks;

namespace Application.Interfaces;

/// <summary>
/// Interface for Deezer API client - supplementary metadata + mainstream charts
/// Base URL: https://api.deezer.com/
/// Only 30s previews available (no full streaming)
/// </summary>
public interface IDeezerApiClient
{
    Task<IEnumerable<TrackDto>> SearchTracksAsync(string query, int limit = 20);
    Task<IEnumerable<TrackDto>> GetChartTracksAsync(int limit = 20);
    Task<TrackDto?> GetTrackAsync(string trackId);
}
