using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class ProfileBadgeRepository : IProfileBadgeRepository
{
    private readonly SoundtiloDbContext _context;

    public ProfileBadgeRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<ProfileBadge?> GetByIdAsync(Guid badgeId)
    {
        return await _context.ProfileBadges.FirstOrDefaultAsync(b => b.Id == badgeId);
    }

    public async Task<ProfileBadge?> GetByCodeAsync(string code)
    {
        return await _context.ProfileBadges.FirstOrDefaultAsync(b => b.Code == code);
    }

    public async Task<IEnumerable<ProfileBadge>> GetAllAsync(bool activeOnly = false)
    {
        var query = _context.ProfileBadges.AsQueryable();
        if (activeOnly)
        {
            query = query.Where(b => b.IsActive);
        }

        return await query
            .OrderBy(b => b.Name)
            .ToListAsync();
    }

    public async Task<ProfileBadge> CreateAsync(ProfileBadge badge)
    {
        _context.ProfileBadges.Add(badge);
        await _context.SaveChangesAsync();
        return badge;
    }
}
