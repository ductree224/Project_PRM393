using Application.DTOs;
using Application.DTOs.Tracks;
using Application.Interfaces;
using Domain.Entities;
using Domain.Interfaces;

namespace Application.Services;

public class AlbumService : IAlbumService
{
    private readonly IAlbumRepository _albumRepository;
    private readonly ITrackCacheRepository _trackCacheRepository;

    public AlbumService(IAlbumRepository albumRepository, ITrackCacheRepository trackCacheRepository)
    {
        _albumRepository = albumRepository;
        _trackCacheRepository = trackCacheRepository;
    }

    public async Task<IEnumerable<AlbumDto>> GetAllAlbumsAsync(string? tag = null, Guid? artistId = null)
    {
        var albums = await _albumRepository.GetAllAsync(tag, artistId);
        return albums.Select(MapToDto);
    }

    public async Task<AlbumDto?> GetAlbumByIdAsync(Guid id, bool includeTracks = false)
    {
        var album = await _albumRepository.GetByIdAsync(id, includeTracks);
        if (album == null) return null;

        var dto = MapToDto(album);

        if (includeTracks && album.AlbumTracks != null && album.AlbumTracks.Any())
        {
            foreach (var at in album.AlbumTracks)
            {
                var track = await _trackCacheRepository.GetByExternalIdAsync(at.TrackExternalId);
                dto.Tracks.Add(new AlbumTrackDto
                {
                    Id = at.Id,
                    TrackExternalId = at.TrackExternalId,
                    Position = at.Position,
                    AddedAt = at.AddedAt,
                    Track = track == null ? null : new TrackDto(
                        track.ExternalId,
                        track.Source,
                        track.Title,
                        track.ArtistName,
                        track.AlbumName,
                        track.ArtworkUrl,
                        track.StreamUrl,
                        track.PreviewUrl,
                        track.DurationSeconds,
                        track.Genre,
                        track.Mood,
                        track.PlayCount
                    )
                });
            }
        }

        return dto;
    }

    public async Task<AlbumDto?> GetAlbumByExternalIdAsync(string externalId)
    {
        var album = await _albumRepository.GetByExternalIdAsync(externalId);
        return album == null ? null : MapToDto(album);
    }

    public async Task<AlbumDto> CreateAlbumAsync(CreateAlbumDto payload)
    {
        var newAlbum = new Album
        {
            Id = Guid.NewGuid(),
            ExternalId = payload.ExternalId ?? string.Empty,
            ArtistId = payload.ArtistId,
            Title = payload.Title,
            Description = payload.Description,
            ReleaseDate = payload.ReleaseDate.HasValue
                ? DateTime.SpecifyKind(payload.ReleaseDate.Value, DateTimeKind.Utc)
                : null,
            CoverImageUrl = payload.CoverImageUrl,
            Tags = payload.Tags ?? new List<string>(),
            IsOverride = payload.IsOverride,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var addedAlbum = await _albumRepository.AddAsync(newAlbum);
        return MapToDto(addedAlbum);
    }

    public async Task UpdateAlbumAsync(Guid id, UpdateAlbumDto payload)
    {
        var album = await _albumRepository.GetByIdAsync(id);
        if (album == null)
        {
            throw new KeyNotFoundException($"Album with ID {id} not found.");
        }

        album.ArtistId = payload.ArtistId;
        album.Title = payload.Title;
        album.Description = payload.Description;
        album.ReleaseDate = payload.ReleaseDate.HasValue
            ? DateTime.SpecifyKind(payload.ReleaseDate.Value, DateTimeKind.Utc)
            : null;
        album.CoverImageUrl = payload.CoverImageUrl;
        album.Tags = payload.Tags ?? new List<string>();
        album.IsOverride = payload.IsOverride;
        album.UpdatedAt = DateTime.UtcNow;

        await _albumRepository.UpdateAsync(album);
    }

    public async Task DeleteAlbumAsync(Guid id)
    {
        var album = await _albumRepository.GetByIdAsync(id);
        if (album == null)
        {
            throw new KeyNotFoundException($"Album with ID {id} not found.");
        }

        await _albumRepository.DeleteAsync(album);
    }

    public async Task AddTrackToAlbumAsync(Guid albumId, AddTrackToAlbumDto payload)
    {
        var album = await _albumRepository.GetByIdAsync(albumId);
        if (album == null)
        {
            throw new KeyNotFoundException($"Album with ID {albumId} not found.");
        }

        var albumTrack = new AlbumTrack
        {
            Id = Guid.NewGuid(),
            AlbumId = albumId,
            TrackExternalId = payload.TrackExternalId,
            Position = payload.Position,
            AddedAt = DateTime.UtcNow
        };

        await _albumRepository.AddTrackAsync(albumTrack);
    }

    public async Task BulkAddTracksToAlbumAsync(BulkAddTracksToAlbumDto payload)
    {
        var album = await _albumRepository.GetByIdAsync(payload.AlbumId, true);
        if (album == null)
        {
            throw new KeyNotFoundException($"Album with ID {payload.AlbumId} not found.");
        }

        var currentMaxPosition = album.AlbumTracks?.Any() == true 
            ? album.AlbumTracks.Max(at => at.Position) 
            : 0;

        var newAlbumTracks = new List<AlbumTrack>();
        foreach (var trackExternalId in payload.TrackExternalIds)
        {
            // Avoid duplicates
            if (album.AlbumTracks?.Any(at => at.TrackExternalId == trackExternalId) == true)
                continue;

            currentMaxPosition++;
            newAlbumTracks.Add(new AlbumTrack
            {
                Id = Guid.NewGuid(),
                AlbumId = payload.AlbumId,
                TrackExternalId = trackExternalId,
                Position = currentMaxPosition,
                AddedAt = DateTime.UtcNow
            });
        }

        if (newAlbumTracks.Any())
        {
            await _albumRepository.AddTracksBulkAsync(newAlbumTracks);
        }
    }

    public async Task RemoveTrackFromAlbumAsync(Guid albumId, string trackExternalId)
    {
        await _albumRepository.RemoveTrackAsync(albumId, trackExternalId);
    }

    private static AlbumDto MapToDto(Album entity)
    {
        return new AlbumDto
        {
            Id = entity.Id,
            ExternalId = entity.ExternalId,
            ArtistId = entity.ArtistId,
            Title = entity.Title,
            Description = entity.Description,
            ReleaseDate = entity.ReleaseDate,
            CoverImageUrl = entity.CoverImageUrl,
            Tags = entity.Tags,
            IsOverride = entity.IsOverride,
            CreatedAt = entity.CreatedAt
        };
    }
}
