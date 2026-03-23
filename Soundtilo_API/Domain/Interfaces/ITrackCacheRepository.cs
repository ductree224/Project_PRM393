using Domain.Entities;

namespace Domain.Interfaces;

public interface ITrackCacheRepository
{
    Task<CachedTrack?> GetByExternalIdAsync(string externalId);
    Task<IEnumerable<CachedTrack>> SearchAsync(string query, string? source = null, int limit = 20, int offset = 0);
    Task<IEnumerable<CachedTrack>> GetCachedTrendingAsync(string? genre = null, int limit = 20, int offset = 0);
    Task<CachedTrack> UpsertAsync(CachedTrack track);
    Task UpsertManyAsync(IEnumerable<CachedTrack> tracks);
    Task CleanExpiredAsync();
}
