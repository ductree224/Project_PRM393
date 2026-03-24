using Application.DTOs;
using Application.DTOs.Tracks;
using Domain.Enums;

namespace Application.Interfaces;

public interface ITrackService
{
    Task<TrackSearchResponse> SearchAsync(string query, string? source = null, int limit = 20, int offset = 0, bool cacheOnly = false, bool fallbackExternal = true);
    Task<TrendingResponse> GetTrendingAsync(string? genre = null, string? time = null, int limit = 20);
    Task<TrackDto?> GetTrackAsync(string externalId, string source = "audius");
    Task<string?> GetStreamUrlAsync(string trackId);
    Task<TrackSearchResponse> GetByTagAsync(string tag, int limit = 20);
    Task<IEnumerable<TrackAdminDto>> GetTracksAsync(TrackStatus? status = null, string? query = null, int limit = 50, int offset = 0);
    Task UpdateStatusesAsync(UpdateTrackStatusDto payload);
}
