using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class UserSettingRepository : IUserSettingRepository
{
    private readonly SoundtiloDbContext _context;

    public UserSettingRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<UserSetting?> GetByUserIdAsync(Guid userId)
    {
        return await _context.UserSettings.FirstOrDefaultAsync(s => s.UserId == userId);
    }

    public async Task<UserSetting> CreateAsync(UserSetting setting)
    {
        _context.UserSettings.Add(setting);
        await _context.SaveChangesAsync();
        return setting;
    }

    public async Task UpdateAsync(UserSetting setting)
    {
        setting.UpdatedAt = DateTime.UtcNow;
        _context.UserSettings.Update(setting);
        await _context.SaveChangesAsync();
    }
}
