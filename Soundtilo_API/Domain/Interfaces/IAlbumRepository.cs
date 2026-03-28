using Domain.Entities;

namespace Domain.Interfaces;

public interface IAlbumRepository
{
    Task<Album?> GetByIdAsync(Guid id, bool includeTracks = false);
    Task<Album?> GetByExternalIdAsync(string externalId);
    Task<IEnumerable<Album>> GetAllAsync(string? tag = null, Guid? artistId = null);
    Task<Album> AddAsync(Album album);
    Task UpdateAsync(Album album);
    Task DeleteAsync(Album album);
    Task<bool> ExistsAsync(Guid id);
    
    // Track management
    Task AddTrackAsync(AlbumTrack albumTrack);
    Task AddTracksBulkAsync(IEnumerable<AlbumTrack> albumTracks);
    Task RemoveTrackAsync(Guid albumId, string trackExternalId);
    Task<IEnumerable<AlbumTrack>> GetTracksAsync(Guid albumId);
}
