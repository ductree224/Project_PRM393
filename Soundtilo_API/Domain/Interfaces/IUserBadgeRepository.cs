using Domain.Entities;

namespace Domain.Interfaces;

public interface IUserBadgeRepository
{
    Task<IEnumerable<UserBadge>> GetByUserIdAsync(Guid userId);
    Task<UserBadge?> GetByUserAndBadgeAsync(Guid userId, Guid badgeId);
    Task<UserBadge> CreateAsync(UserBadge userBadge);
    Task DeleteAsync(UserBadge userBadge);
}
