namespace Application.DTOs.Users;

public record UserProfileDto(
    Guid Id,
    string Username,
    string Email,
    string? DisplayName,
    string? AvatarUrl,
    DateTime CreatedAt,
    int TotalListens,
    int TotalListeningTimeSeconds,
    int TotalFavorites,
    int TotalPlaylists
);

public record UpdateProfileRequest(
    string? DisplayName,
    string? AvatarUrl
);
