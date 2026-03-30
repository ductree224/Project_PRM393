using Application.DTOs.Users;
using Application.Interfaces;
using Domain.Interfaces;

namespace Application.Services;

public class UserService
{
    private readonly IUserRepository _userRepository;
    private readonly IHistoryRepository _historyRepository;
    private readonly IFavoriteRepository _favoriteRepository;
    private readonly IPlaylistRepository _playlistRepository;
    private readonly IPasswordHasher _passwordHasher;

    public UserService(
        IUserRepository userRepository,
        IHistoryRepository historyRepository,
        IFavoriteRepository favoriteRepository,
        IPlaylistRepository playlistRepository,
        IPasswordHasher passwordHasher)
    {
        _userRepository = userRepository;
        _historyRepository = historyRepository;
        _favoriteRepository = favoriteRepository;
        _playlistRepository = playlistRepository;
        _passwordHasher = passwordHasher;
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
    public async Task<bool> ChangePasswordAsync(Guid userId, ChangePasswordRequest request)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null) return false;

        // Dùng _passwordHasher thay vì BCrypt
        bool isOldPasswordValid = _passwordHasher.Verify(request.OldPassword, user.PasswordHash);

        if (!isOldPasswordValid)
        {
            throw new UnauthorizedAccessException("Mật khẩu hiện tại không chính xác.");
        }

        // Dùng _passwordHasher thay vì BCrypt
        user.PasswordHash = _passwordHasher.Hash(request.NewPassword);
        user.UpdatedAt = DateTime.UtcNow; // Nên cập nhật thêm thời gian sửa đổi

        await _userRepository.UpdateAsync(user);

        return true;
    }
}
