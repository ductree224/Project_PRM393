using Application.DTOs.Users;
using Domain.Interfaces;

namespace Application.Services;

public class UserService
{
    private readonly IUserRepository _userRepository;
    private readonly IHistoryRepository _historyRepository;
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly IPlaylistRepository _playlistRepository;

    public UserService(
        IUserRepository userRepository,
        IHistoryRepository historyRepository,
        IFavoriteRepository favoriteRepository,
        IPlaylistRepository playlistRepository)
    {
        _userRepository = userRepository;
        _historyRepository = historyRepository;
        _favoriteRepository = favoriteRepository;
        _playlistRepository = playlistRepository;
    }

    public async Task<UserProfileDto?> GetProfileAsync(Guid userId)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return null;

        var totalListens = await _historyRepository.GetTotalListensAsync(userId);
        var totalTime = await _historyRepository.GetTotalListeningTimeAsync(userId);
        var totalFavorites = await _favoriteRepository.GetCountAsync(userId);
        var playlists = await _playlistRepository.GetByUserIdAsync(userId);

        return new UserProfileDto(
            Id: user.Id,
            Username: user.Username,
            Email: user.Email,
            DisplayName: user.DisplayName,
            AvatarUrl: user.AvatarUrl,
            CreatedAt: user.CreatedAt,
            TotalListens: totalListens,
            TotalListeningTimeSeconds: totalTime,
            TotalFavorites: totalFavorites,
            TotalPlaylists: playlists.Count()
        );
    }

    public async Task<UserProfileDto?> UpdateProfileAsync(Guid userId, UpdateProfileRequest request)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return null;

        if (request.DisplayName != null) user.DisplayName = request.DisplayName;
        if (request.AvatarUrl != null) user.AvatarUrl = request.AvatarUrl;

        await _userRepository.UpdateAsync(user);

        return await GetProfileAsync(userId);
    }
}
