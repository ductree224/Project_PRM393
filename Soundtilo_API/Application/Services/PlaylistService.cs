using Application.DTOs.Playlists;
using Domain.Entities;
using Domain.Interfaces;

namespace Application.Services;

public class PlaylistService
{
    private readonly IPlaylistRepository _playlistRepository;

    public PlaylistService(IPlaylistRepository playlistRepository)
    {
        _playlistRepository = playlistRepository;
    }

    public async Task<IEnumerable<PlaylistDto>> GetUserPlaylistsAsync(Guid userId)
    {
        var playlists = await _playlistRepository.GetByUserIdAsync(userId);
        return playlists.Select(p => new PlaylistDto(
            Id: p.Id,
            Name: p.Name,
            Description: p.Description,
            CoverImageUrl: p.CoverImageUrl,
            IsPublic: p.IsPublic,
            TrackCount: p.PlaylistTracks.Count,
            CreatedAt: p.CreatedAt,
            UpdatedAt: p.UpdatedAt
        ));
    }

    public async Task<PlaylistDetailDto?> GetPlaylistDetailAsync(Guid playlistId, Guid userId)
    {
        var playlist = await _playlistRepository.GetByIdAsync(playlistId);
        if (playlist == null) return null;

        // Only owner or public playlists
        if (playlist.UserId != userId && !playlist.IsPublic)
            throw new UnauthorizedAccessException("Bạn không có quyền xem playlist này.");

        return new PlaylistDetailDto(
            Id: playlist.Id,
            Name: playlist.Name,
            Description: playlist.Description,
            CoverImageUrl: playlist.CoverImageUrl,
            IsPublic: playlist.IsPublic,
            Tracks: playlist.PlaylistTracks.OrderBy(t => t.Position).Select(t => new PlaylistTrackDto(
                TrackExternalId: t.TrackExternalId,
                Position: t.Position,
                AddedAt: t.AddedAt
            )),
            CreatedAt: playlist.CreatedAt,
            UpdatedAt: playlist.UpdatedAt
        );
    }

    public async Task<PlaylistDto> CreatePlaylistAsync(Guid userId, CreatePlaylistRequest request)
    {
        var playlist = new Playlist
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Name = request.Name,
            Description = request.Description,
            IsPublic = request.IsPublic,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        await _playlistRepository.CreateAsync(playlist);

        return new PlaylistDto(
            Id: playlist.Id,
            Name: playlist.Name,
            Description: playlist.Description,
            CoverImageUrl: playlist.CoverImageUrl,
            IsPublic: playlist.IsPublic,
            TrackCount: 0,
            CreatedAt: playlist.CreatedAt,
            UpdatedAt: playlist.UpdatedAt
        );
    }

    public async Task<PlaylistDto?> UpdatePlaylistAsync(Guid playlistId, Guid userId, UpdatePlaylistRequest request)
    {
        var playlist = await _playlistRepository.GetByIdAsync(playlistId);
        if (playlist == null) return null;
        if (playlist.UserId != userId)
            throw new UnauthorizedAccessException("Bạn không có quyền chỉnh sửa playlist này.");

        if (request.Name != null) playlist.Name = request.Name;
        if (request.Description != null) playlist.Description = request.Description;
        if (request.IsPublic.HasValue) playlist.IsPublic = request.IsPublic.Value;

        await _playlistRepository.UpdateAsync(playlist);

        return new PlaylistDto(
            Id: playlist.Id,
            Name: playlist.Name,
            Description: playlist.Description,
            CoverImageUrl: playlist.CoverImageUrl,
            IsPublic: playlist.IsPublic,
            TrackCount: playlist.PlaylistTracks.Count,
            CreatedAt: playlist.CreatedAt,
            UpdatedAt: playlist.UpdatedAt
        );
    }

    public async Task DeletePlaylistAsync(Guid playlistId, Guid userId)
    {
        var playlist = await _playlistRepository.GetByIdAsync(playlistId);
        if (playlist == null)
            throw new KeyNotFoundException("Playlist không tồn tại.");
        if (playlist.UserId != userId)
            throw new UnauthorizedAccessException("Bạn không có quyền xoá playlist này.");

        await _playlistRepository.DeleteAsync(playlistId);
    }

    public async Task AddTrackAsync(Guid playlistId, Guid userId, AddTrackToPlaylistRequest request)
    {
        var playlist = await _playlistRepository.GetByIdAsync(playlistId);
        if (playlist == null)
            throw new KeyNotFoundException("Playlist không tồn tại.");
        if (playlist.UserId != userId)
            throw new UnauthorizedAccessException("Bạn không có quyền thêm bài vào playlist này.");

        var maxPosition = playlist.PlaylistTracks.Any() ? playlist.PlaylistTracks.Max(t => t.Position) : -1;

        await _playlistRepository.AddTrackAsync(new PlaylistTrack
        {
            Id = Guid.NewGuid(),
            PlaylistId = playlistId,
            TrackExternalId = request.TrackExternalId,
            Position = maxPosition + 1,
            AddedAt = DateTime.UtcNow
        });
    }

    public async Task RemoveTrackAsync(Guid playlistId, Guid userId, string trackExternalId)
    {
        var playlist = await _playlistRepository.GetByIdAsync(playlistId);
        if (playlist == null)
            throw new KeyNotFoundException("Playlist không tồn tại.");
        if (playlist.UserId != userId)
            throw new UnauthorizedAccessException("Bạn không có quyền xoá bài khỏi playlist này.");

        await _playlistRepository.RemoveTrackAsync(playlistId, trackExternalId);
    }

    public async Task ReorderTracksAsync(Guid playlistId, Guid userId, ReorderTracksRequest request)
    {
        var playlist = await _playlistRepository.GetByIdAsync(playlistId);
        if (playlist == null)
            throw new KeyNotFoundException("Playlist không tồn tại.");
        if (playlist.UserId != userId)
            throw new UnauthorizedAccessException("Bạn không có quyền sắp xếp lại playlist này.");

        await _playlistRepository.ReorderTracksAsync(playlistId, request.TrackExternalIds);
    }
}
