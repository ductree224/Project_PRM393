using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class PlaylistRepository : IPlaylistRepository
{
    private readonly SoundtiloDbContext _context;

    public PlaylistRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<Playlist?> GetByIdAsync(Guid id)
    {
        var playlist = await _context.Playlists
            .Include(p => p.PlaylistTracks)
            .FirstOrDefaultAsync(p => p.Id == id);

        if (playlist != null)
        {
            // Filter PlaylistTracks by status in CachedTracks
            var activeTrackIds = await _context.CachedTracks
                .Where(t => playlist.PlaylistTracks.Select(pt => pt.TrackExternalId).Contains(t.ExternalId) 
                         && t.Status == Domain.Enums.TrackStatus.Active)
                .Select(t => t.ExternalId)
                .ToListAsync();

            playlist.PlaylistTracks = playlist.PlaylistTracks
                .Where(pt => activeTrackIds.Contains(pt.TrackExternalId))
                .ToList();
        }

        return playlist;
    }

    public async Task<IEnumerable<Playlist>> GetByUserIdAsync(Guid userId)
    {
        return await _context.Playlists
            .Include(p => p.PlaylistTracks)
            .Where(p => p.UserId == userId)
            .OrderByDescending(p => p.UpdatedAt)
            .ToListAsync();
    }

    public async Task<(IEnumerable<Playlist> Playlists, int Total)> GetPagedByUserIdAsync(Guid userId, int page = 1, int pageSize = 20)
    {
        var safePage = Math.Max(page, 1);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var query = _context.Playlists
            .Include(p => p.PlaylistTracks)
            .Where(p => p.UserId == userId);

        var total = await query.CountAsync();
        var playlists = await query
            .OrderByDescending(p => p.UpdatedAt)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .ToListAsync();

        return (playlists, total);
    }

    public async Task<Playlist> CreateAsync(Playlist playlist)
    {
        _context.Playlists.Add(playlist);
        await _context.SaveChangesAsync();
        return playlist;
    }

    public async Task UpdateAsync(Playlist playlist)
    {
        playlist.UpdatedAt = DateTime.UtcNow;
        _context.Playlists.Update(playlist);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Guid id)
    {
        var playlist = await _context.Playlists.FindAsync(id);
        if (playlist != null)
        {
            _context.Playlists.Remove(playlist);
            await _context.SaveChangesAsync();
        }
    }

    public async Task AddTrackAsync(PlaylistTrack playlistTrack)
    {
        _context.PlaylistTracks.Add(playlistTrack);
        await _context.SaveChangesAsync();
    }

    public async Task RemoveTrackAsync(Guid playlistId, string trackExternalId)
    {
        var track = await _context.PlaylistTracks
            .FirstOrDefaultAsync(pt => pt.PlaylistId == playlistId && pt.TrackExternalId == trackExternalId);
        if (track != null)
        {
            _context.PlaylistTracks.Remove(track);
            await _context.SaveChangesAsync();
        }
    }

    public async Task ReorderTracksAsync(Guid playlistId, List<string> trackExternalIds)
    {
        var tracks = await _context.PlaylistTracks
            .Where(pt => pt.PlaylistId == playlistId)
            .ToListAsync();

        for (int i = 0; i < trackExternalIds.Count; i++)
        {
            var track = tracks.FirstOrDefault(t => t.TrackExternalId == trackExternalIds[i]);
            if (track != null)
            {
                track.Position = i;
            }
        }

        await _context.SaveChangesAsync();
    }
}
