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
    public string SubscriptionTier { get; set; } = "free"; // free | premium
    public DateTime? PremiumExpiresAt { get; set; }
    public string? StripeCustomerId { get; set; }
    public string? Bio { get; set; }
    public DateTime? Birthday { get; set; }
    public string? Gender { get; set; }
    public string? Pronouns { get; set; }
    public bool IsProfilePublic { get; set; } = true;
    public string? StatusMessage { get; set; }
    public bool AllowComments { get; set; } = true;
    public bool AllowMessages { get; set; } = true;
    public string FollowerPrivacyMode { get; set; } = "everyone";

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
    public Subscription? Subscription { get; set; }
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<PaymentTransaction> PaymentTransactions { get; set; } = new List<PaymentTransaction>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<UserBlock> BlocksInitiated { get; set; } = new List<UserBlock>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<UserBlock> BlocksReceived { get; set; } = new List<UserBlock>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<UserBadge> UserBadges { get; set; } = new List<UserBadge>();
    [System.Text.Json.Serialization.JsonIgnore]
    public ICollection<UserBadge> BadgesAssigned { get; set; } = new List<UserBadge>();
}
