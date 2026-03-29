using Domain.Entities;

namespace Domain.Interfaces;

public interface IUserBlockRepository
{
    Task<UserBlock?> GetByBlockerAndBlockedAsync(Guid blockerId, Guid blockedId);
    Task<IEnumerable<UserBlock>> GetBlockedUsersAsync(Guid blockerId);
    Task<UserBlock> CreateAsync(UserBlock block);
    Task DeleteAsync(UserBlock block);
}
