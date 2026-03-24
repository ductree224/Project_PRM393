namespace Domain.Entities;

public class User
{
    public Guid Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public string? AvatarUrl { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public string Role { get; set; } = "User";

    // Navigation properties
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<Playlist> Playlists { get; set; } = new List<Playlist>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<Favorite> Favorites { get; set; } = new List<Favorite>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<ListeningHistory> ListeningHistories { get; set; } = new List<ListeningHistory>();
    [System.Text.Json.Serialization.JsonIgnore]
    public UserSetting? UserSetting { get; set; }
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<PasswordResetToken> PasswordResetTokens { get; set; } = new List<PasswordResetToken>();
}
