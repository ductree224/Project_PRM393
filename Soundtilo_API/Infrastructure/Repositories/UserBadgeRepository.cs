using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class UserBadgeRepository : IUserBadgeRepository
{
    private readonly SoundtiloDbContext _context;

    public UserBadgeRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<UserBadge>> GetByUserIdAsync(Guid userId)
    {
        return await _context.UserBadges
            .Include(ub => ub.Badge)
            .Where(ub => ub.UserId == userId)
            .OrderByDescending(ub => ub.AssignedAt)
            .ToListAsync();
    }

    public async Task<UserBadge?> GetByUserAndBadgeAsync(Guid userId, Guid badgeId)
    {
        return await _context.UserBadges
            .FirstOrDefaultAsync(ub => ub.UserId == userId && ub.BadgeId == badgeId);
    }

    public async Task<UserBadge> CreateAsync(UserBadge userBadge)
    {
        _context.UserBadges.Add(userBadge);
        await _context.SaveChangesAsync();
        return userBadge;
    }

    public async Task DeleteAsync(UserBadge userBadge)
    {
        _context.UserBadges.Remove(userBadge);
        await _context.SaveChangesAsync();
    }
}
