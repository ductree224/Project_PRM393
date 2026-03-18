namespace Domain.Entities;

public class UserSetting
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string ThemeMode { get; set; } = "system";
    public string AudioQuality { get; set; } = "medium";
    public DateTime UpdatedAt { get; set; }

    // Navigation properties
    public User User { get; set; } = null!;
}
