using Domain.Entities;

namespace Domain.Interfaces;

public interface IPlaylistRepository
{
    Task<Playlist?> GetByIdAsync(Guid id);
    Task<IEnumerable<Playlist>> GetByUserIdAsync(Guid userId);
    Task<(IEnumerable<Playlist> Playlists, int Total)> GetPagedByUserIdAsync(Guid userId, int page = 1, int pageSize = 20);
    Task<Playlist> CreateAsync(Playlist playlist);
    Task UpdateAsync(Playlist playlist);
    Task DeleteAsync(Guid id);
    Task AddTrackAsync(PlaylistTrack playlistTrack);
    Task RemoveTrackAsync(Guid playlistId, string trackExternalId);
    Task ReorderTracksAsync(Guid playlistId, List<string> trackExternalIds);
}
