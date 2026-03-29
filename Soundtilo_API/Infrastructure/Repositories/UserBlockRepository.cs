using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class UserBlockRepository : IUserBlockRepository
{
    private readonly SoundtiloDbContext _context;

    public UserBlockRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<UserBlock?> GetByBlockerAndBlockedAsync(Guid blockerId, Guid blockedId)
    {
        return await _context.UserBlocks
            .FirstOrDefaultAsync(b => b.BlockerId == blockerId && b.BlockedId == blockedId);
    }

    public async Task<IEnumerable<UserBlock>> GetBlockedUsersAsync(Guid blockerId)
    {
        return await _context.UserBlocks
            .Include(b => b.Blocked)
            .Where(b => b.BlockerId == blockerId)
            .OrderByDescending(b => b.CreatedAt)
            .ToListAsync();
    }

    public async Task<UserBlock> CreateAsync(UserBlock block)
    {
        _context.UserBlocks.Add(block);
        await _context.SaveChangesAsync();
        return block;
    }

    public async Task DeleteAsync(UserBlock block)
    {
        _context.UserBlocks.Remove(block);
        await _context.SaveChangesAsync();
    }
}
