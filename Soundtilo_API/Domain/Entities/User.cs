namespace Domain.Entities;

public class User
{
    public Guid Id { get; set; }
    public string Username { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string? DisplayName { get; set; }
    public string? AvatarUrl { get; set; }
    public string Role { get; set; } = "user";
    public bool IsBanned { get; set; } = false;
    public DateTime? BannedAt { get; set; }
    public string? BannedReason { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }


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
    public ICollection<AdminAuditLog> AdminAuditLogs { get; set; } = new List<AdminAuditLog>();
    public ICollection<Comment> Comments { get; set; } = new List<Comment>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<Notification> Notifications { get; set; } = new List<Notification>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<NotificationTemplate> NotificationTemplatesCreated { get; set; } = new List<NotificationTemplate>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<NotificationSchedule> NotificationSchedulesCreated { get; set; } = new List<NotificationSchedule>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<NotificationSchedule> NotificationSchedulesTargeted { get; set; } = new List<NotificationSchedule>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<NotificationDeliveryLog> NotificationDeliveryLogs { get; set; } = new List<NotificationDeliveryLog>();
}
