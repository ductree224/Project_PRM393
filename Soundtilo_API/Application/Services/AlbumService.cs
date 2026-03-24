using Application.DTOs;
using Application.Interfaces;
using Domain.Entities;
using Domain.Interfaces;

namespace Application.Services;

public class AlbumService : IAlbumService
{
    private readonly IAlbumRepository _albumRepository;

    public AlbumService(IAlbumRepository albumRepository)
    {
        _albumRepository = albumRepository;
    }

    public async Task<IEnumerable<AlbumDto>> GetAllAlbumsAsync(string? tag = null, Guid? artistId = null)
    {
        var albums = await _albumRepository.GetAllAsync(tag, artistId);
        return albums.Select(MapToDto);
    }

    public async Task<AlbumDto?> GetAlbumByIdAsync(Guid id)
    {
        var album = await _albumRepository.GetByIdAsync(id);
        return album == null ? null : MapToDto(album);
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
            ReleaseDate = payload.ReleaseDate,
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
        album.ReleaseDate = payload.ReleaseDate;
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
