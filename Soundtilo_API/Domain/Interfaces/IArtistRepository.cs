using Domain.Entities;

namespace Domain.Interfaces;

public interface IArtistRepository
{
    Task<Artist?> GetByIdAsync(Guid id);
    Task<Artist?> GetByExternalIdAsync(string externalId);
    Task<IEnumerable<Artist>> GetAllAsync(string? tag = null);
    Task<Artist> AddAsync(Artist artist);
    Task UpdateAsync(Artist artist);
    Task DeleteAsync(Artist artist);
    Task<bool> ExistsAsync(Guid id);
}
