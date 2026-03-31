using Domain.Entities;

namespace Domain.Interfaces;

public interface IHistoryRepository
{
    Task<IEnumerable<ListeningHistory>> GetByUserIdAsync(Guid userId, int page = 1, int pageSize = 20);
    Task<ListeningHistory> AddAsync(ListeningHistory history);
    Task<ListeningHistory> UpsertAsync(ListeningHistory history);
    Task<int> DeleteByIdsAsync(Guid userId, IReadOnlyCollection<Guid> historyIds);
    Task<int> GetTotalListensAsync(Guid userId);
    Task<int> GetTotalListeningTimeAsync(Guid userId); // in seconds
}
