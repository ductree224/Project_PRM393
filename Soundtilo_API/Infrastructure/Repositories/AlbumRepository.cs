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

    public async Task<Album?> GetByIdAsync(Guid id, bool includeTracks = false)
    {
        var query = _context.Albums.AsQueryable();
        if (includeTracks)
        {
            query = query.Include(a => a.AlbumTracks);
        }
        return await query.FirstOrDefaultAsync(a => a.Id == id);
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

    public async Task AddTrackAsync(AlbumTrack albumTrack)
    {
        _context.AlbumTracks.Add(albumTrack);
        await _context.SaveChangesAsync();
    }

    public async Task RemoveTrackAsync(Guid albumId, string trackExternalId)
    {
        var albumTrack = await _context.AlbumTracks
            .FirstOrDefaultAsync(at => at.AlbumId == albumId && at.TrackExternalId == trackExternalId);
        
        if (albumTrack != null)
        {
            _context.AlbumTracks.Remove(albumTrack);
            await _context.SaveChangesAsync();
        }
    }

    public async Task<IEnumerable<AlbumTrack>> GetTracksAsync(Guid albumId)
    {
        return await _context.AlbumTracks
            .Where(at => at.AlbumId == albumId)
            .OrderBy(at => at.Position)
            .ToListAsync();
    }
}
