using Domain.Entities;

namespace Domain.Interfaces;

public interface IProfileBadgeRepository
{
    Task<ProfileBadge?> GetByIdAsync(Guid badgeId);
    Task<ProfileBadge?> GetByCodeAsync(string code);
    Task<IEnumerable<ProfileBadge>> GetAllAsync(bool activeOnly = false);
    Task<ProfileBadge> CreateAsync(ProfileBadge badge);
}
