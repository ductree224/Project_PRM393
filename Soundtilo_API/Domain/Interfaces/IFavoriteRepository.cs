using Domain.Entities;

namespace Domain.Interfaces;

public interface IFavoriteRepository
{
    Task<IEnumerable<Favorite>> GetByUserIdAsync(Guid userId, int page = 1, int pageSize = 20);
    Task<bool> IsFavoriteAsync(Guid userId, string trackExternalId);
    Task<Favorite> AddAsync(Favorite favorite);
    Task RemoveAsync(Guid userId, string trackExternalId);
    Task<int> GetCountAsync(Guid userId);
}
