using Application.DTOs.Favorites;
using Domain.Entities;
using Domain.Interfaces;

namespace Application.Services;

public class FavoriteService
{
    private readonly IFavoriteRepository _favoriteRepository;

    public FavoriteService(IFavoriteRepository favoriteRepository)
    {
        _favoriteRepository = favoriteRepository;
    }

    public async Task<FavoriteListResponse> GetFavoritesAsync(Guid userId, int page = 1, int pageSize = 20)
    {
        var favorites = await _favoriteRepository.GetByUserIdAsync(userId, page, pageSize);
        var totalCount = await _favoriteRepository.GetCountAsync(userId);

        return new FavoriteListResponse(
            Favorites: favorites.Select(f => new FavoriteDto(
                TrackExternalId: f.TrackExternalId,
                CreatedAt: f.CreatedAt
            )),
            TotalCount: totalCount
        );
    }

    public async Task<ToggleFavoriteResponse> ToggleFavoriteAsync(Guid userId, string trackExternalId)
    {
        var isFavorite = await _favoriteRepository.IsFavoriteAsync(userId, trackExternalId);

        if (isFavorite)
        {
            await _favoriteRepository.RemoveAsync(userId, trackExternalId);
            return new ToggleFavoriteResponse(IsFavorite: false);
        }

        await _favoriteRepository.AddAsync(new Favorite
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TrackExternalId = trackExternalId,
            CreatedAt = DateTime.UtcNow
        });

        return new ToggleFavoriteResponse(IsFavorite: true);
    }

    public async Task<bool> IsFavoriteAsync(Guid userId, string trackExternalId)
    {
        return await _favoriteRepository.IsFavoriteAsync(userId, trackExternalId);
    }
}
