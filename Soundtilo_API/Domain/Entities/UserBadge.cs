namespace Domain.Entities;

public class UserBadge
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid BadgeId { get; set; }
    public Guid? AssignedByAdminId { get; set; }
    public DateTime AssignedAt { get; set; }
    public string? Note { get; set; }

    [System.Text.Json.Serialization.JsonIgnore]
    public User User { get; set; } = null!;

    [System.Text.Json.Serialization.JsonIgnore]
    public ProfileBadge Badge { get; set; } = null!;

    [System.Text.Json.Serialization.JsonIgnore]
    public User? AssignedByAdmin { get; set; }
}
