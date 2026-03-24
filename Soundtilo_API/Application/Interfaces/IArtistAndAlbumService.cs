using Application.DTOs;

namespace Application.Interfaces;

public interface IArtistService
{
    Task<IEnumerable<ArtistDto>> GetAllArtistsAsync(string? tag = null);
    Task<ArtistDto?> GetArtistByIdAsync(Guid id);
    Task<ArtistDto?> GetArtistByExternalIdAsync(string externalId);
    Task<ArtistDto> CreateArtistAsync(CreateArtistDto payload);
    Task UpdateArtistAsync(Guid id, UpdateArtistDto payload);
    Task DeleteArtistAsync(Guid id);
}

public interface IAlbumService
{
    Task<IEnumerable<AlbumDto>> GetAllAlbumsAsync(string? tag = null, Guid? artistId = null);
    Task<AlbumDto?> GetAlbumByIdAsync(Guid id);
    Task<AlbumDto?> GetAlbumByExternalIdAsync(string externalId);
    Task<AlbumDto> CreateAlbumAsync(CreateAlbumDto payload);
    Task UpdateAlbumAsync(Guid id, UpdateAlbumDto payload);
    Task DeleteAlbumAsync(Guid id);
}
