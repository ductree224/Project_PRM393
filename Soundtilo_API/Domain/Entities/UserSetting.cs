namespace Domain.Entities;

public class UserSetting
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string ThemeMode { get; set; } = "system";
    public string AudioQuality { get; set; } = "medium";
    public bool ShowTotalListens { get; set; } = true;
    public bool ShowTotalFavorites { get; set; } = true;
    public bool ShowTotalPlaylists { get; set; } = true;
    public bool ShowListeningTime { get; set; } = true;
    public bool ShowRecentlyPlayed { get; set; } = true;
    public DateTime UpdatedAt { get; set; }

    // Navigation properties
    [System.Text.Json.Serialization.JsonIgnore]
    public User User { get; set; } = null!;
}
