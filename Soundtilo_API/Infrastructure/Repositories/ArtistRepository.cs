using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class ArtistRepository : IArtistRepository
{
    private readonly SoundtiloDbContext _context;

    public ArtistRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<Artist?> GetByIdAsync(Guid id)
    {
        return await _context.Artists.FindAsync(id);
    }

    public async Task<Artist?> GetByExternalIdAsync(string externalId)
    {
        return await _context.Artists.FirstOrDefaultAsync(a => a.ExternalId == externalId);
    }

    public async Task<IEnumerable<Artist>> GetAllAsync(string? tag = null)
    {
        var query = _context.Artists.AsQueryable();

        if (!string.IsNullOrWhiteSpace(tag))
        {
            query = query.Where(a => a.Tags.Contains(tag));
        }

        return await query.ToListAsync();
    }

    public async Task<Artist> AddAsync(Artist artist)
    {
        _context.Artists.Add(artist);
        await _context.SaveChangesAsync();
        return artist;
    }

    public async Task UpdateAsync(Artist artist)
    {
        artist.UpdatedAt = DateTime.UtcNow;
        _context.Artists.Update(artist);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Artist artist)
    {
        _context.Artists.Remove(artist);
        await _context.SaveChangesAsync();
    }

    public async Task<bool> ExistsAsync(Guid id)
    {
        return await _context.Artists.AnyAsync(a => a.Id == id);
    }
}
