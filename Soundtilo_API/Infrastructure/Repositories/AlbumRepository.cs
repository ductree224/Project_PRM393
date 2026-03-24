using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class AlbumRepository : IAlbumRepository
{
    private readonly SoundtiloDbContext _context;

    public AlbumRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<Album?> GetByIdAsync(Guid id)
    {
        return await _context.Albums.FindAsync(id);
    }

    public async Task<Album?> GetByExternalIdAsync(string externalId)
    {
        return await _context.Albums.FirstOrDefaultAsync(a => a.ExternalId == externalId);
    }

    public async Task<IEnumerable<Album>> GetAllAsync(string? tag = null, Guid? artistId = null)
    {
        var query = _context.Albums.AsQueryable();

        if (!string.IsNullOrWhiteSpace(tag))
        {
            query = query.Where(a => a.Tags.Contains(tag));
        }

        if (artistId.HasValue)
        {
            query = query.Where(a => a.ArtistId == artistId.Value);
        }

        return await query.ToListAsync();
    }

    public async Task<Album> AddAsync(Album album)
    {
        _context.Albums.Add(album);
        await _context.SaveChangesAsync();
        return album;
    }

    public async Task UpdateAsync(Album album)
    {
        album.UpdatedAt = DateTime.UtcNow;
        _context.Albums.Update(album);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Album album)
    {
        _context.Albums.Remove(album);
        await _context.SaveChangesAsync();
    }

    public async Task<bool> ExistsAsync(Guid id)
    {
        return await _context.Albums.AnyAsync(a => a.Id == id);
    }
}
