using Application.DTOs;
using Application.Interfaces;
using Domain.Entities;
using Domain.Interfaces;

namespace Application.Services;

public class ArtistService : IArtistService
{
    private readonly IArtistRepository _artistRepository;

    public ArtistService(IArtistRepository artistRepository)
    {
        _artistRepository = artistRepository;
    }

    public async Task<IEnumerable<ArtistDto>> GetAllArtistsAsync(string? tag = null)
    {
        var artists = await _artistRepository.GetAllAsync(tag);
        return artists.Select(MapToDto);
    }

    public async Task<ArtistDto?> GetArtistByIdAsync(Guid id)
    {
        var artist = await _artistRepository.GetByIdAsync(id);
        return artist == null ? null : MapToDto(artist);
    }

    public async Task<ArtistDto?> GetArtistByExternalIdAsync(string externalId)
    {
        var artist = await _artistRepository.GetByExternalIdAsync(externalId);
        return artist == null ? null : MapToDto(artist);
    }

    public async Task<ArtistDto> CreateArtistAsync(CreateArtistDto payload)
    {
        var newArtist = new Artist
        {
            Id = Guid.NewGuid(),
            ExternalId = payload.ExternalId ?? string.Empty,
            Name = payload.Name,
            Bio = payload.Bio,
            ImageUrl = payload.ImageUrl,
            Tags = payload.Tags ?? new List<string>(),
            IsOverride = payload.IsOverride,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };

        var addedArtist = await _artistRepository.AddAsync(newArtist);
        return MapToDto(addedArtist);
    }

    public async Task UpdateArtistAsync(Guid id, UpdateArtistDto payload)
    {
        var artist = await _artistRepository.GetByIdAsync(id);
        if (artist == null)
        {
            throw new KeyNotFoundException($"Artist with ID {id} not found.");
        }

        artist.Name = payload.Name;
        artist.Bio = payload.Bio;
        artist.ImageUrl = payload.ImageUrl;
        artist.Tags = payload.Tags ?? new List<string>();
        artist.IsOverride = payload.IsOverride;
        artist.UpdatedAt = DateTime.UtcNow;

        await _artistRepository.UpdateAsync(artist);
    }

    public async Task DeleteArtistAsync(Guid id)
    {
        var artist = await _artistRepository.GetByIdAsync(id);
        if (artist == null)
        {
            throw new KeyNotFoundException($"Artist with ID {id} not found.");
        }

        await _artistRepository.DeleteAsync(artist);
    }

    private static ArtistDto MapToDto(Artist entity)
    {
        return new ArtistDto
        {
            Id = entity.Id,
            ExternalId = entity.ExternalId,
            Name = entity.Name,
            Bio = entity.Bio,
            ImageUrl = entity.ImageUrl,
            Tags = entity.Tags,
            IsOverride = entity.IsOverride,
            CreatedAt = entity.CreatedAt
        };
    }
}
