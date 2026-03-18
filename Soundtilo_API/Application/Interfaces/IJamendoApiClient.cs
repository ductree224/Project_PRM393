using Application.DTOs.Tracks;

namespace Application.Interfaces;

/// <summary>
/// Interface for Jamendo API client - CC-licensed music with full free streaming.
/// Base URL: https://api.jamendo.com/v3.0/
/// Requires a free client_id from https://developer.jamendo.com/
/// Supports: search, trending/popular, genres, full MP3 streaming
/// </summary>
public interface IJamendoApiClient
{
    Task<IEnumerable<TrackDto>> SearchTracksAsync(string query, int limit = 20);
    Task<IEnumerable<TrackDto>> GetPopularTracksAsync(int limit = 20);
    Task<IEnumerable<TrackDto>> GetTracksByTagAsync(string tag, int limit = 20);
    Task<TrackDto?> GetTrackAsync(string trackId);
    Task<string?> GetStreamUrlAsync(string trackId);
}
