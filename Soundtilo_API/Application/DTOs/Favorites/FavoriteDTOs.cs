namespace Application.DTOs.Favorites;

public record FavoriteDto(
    string TrackExternalId,
    DateTime CreatedAt
);

public record FavoriteListResponse(
    IEnumerable<FavoriteDto> Favorites,
    int TotalCount
);

public record ToggleFavoriteResponse(
    bool IsFavorite
);
