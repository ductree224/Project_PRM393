using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class FavoriteRepository : IFavoriteRepository
{
    private readonly SoundtiloDbContext _context;

    public FavoriteRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Favorite>> GetByUserIdAsync(Guid userId, int page = 1, int pageSize = 20)
    {
        return await _context.Favorites
            .Where(f => f.UserId == userId)
            .OrderByDescending(f => f.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task<bool> IsFavoriteAsync(Guid userId, string trackExternalId)
    {
        return await _context.Favorites.AnyAsync(f => f.UserId == userId && f.TrackExternalId == trackExternalId);
    }

    public async Task<Favorite> AddAsync(Favorite favorite)
    {
        _context.Favorites.Add(favorite);
        await _context.SaveChangesAsync();
        return favorite;
    }

    public async Task RemoveAsync(Guid userId, string trackExternalId)
    {
        var favorite = await _context.Favorites
            .FirstOrDefaultAsync(f => f.UserId == userId && f.TrackExternalId == trackExternalId);
        if (favorite != null)
        {
            _context.Favorites.Remove(favorite);
            await _context.SaveChangesAsync();
        }
    }

    public async Task<int> GetCountAsync(Guid userId)
    {
        return await _context.Favorites.CountAsync(f => f.UserId == userId);
    }
}
