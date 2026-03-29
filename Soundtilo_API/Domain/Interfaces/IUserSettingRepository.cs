using Domain.Entities;

namespace Domain.Interfaces;

public interface IUserSettingRepository
{
    Task<UserSetting?> GetByUserIdAsync(Guid userId);
    Task<UserSetting> CreateAsync(UserSetting setting);
    Task UpdateAsync(UserSetting setting);
}
