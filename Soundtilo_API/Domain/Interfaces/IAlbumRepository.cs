using Domain.Entities;

namespace Domain.Interfaces;

public interface IAlbumRepository
{
    Task<Album?> GetByIdAsync(Guid id);
    Task<Album?> GetByExternalIdAsync(string externalId);
    Task<IEnumerable<Album>> GetAllAsync(string? tag = null, Guid? artistId = null);
    Task<Album> AddAsync(Album album);
    Task UpdateAsync(Album album);
    Task DeleteAsync(Album album);
    Task<bool> ExistsAsync(Guid id);
}
