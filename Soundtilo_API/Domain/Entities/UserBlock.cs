namespace Domain.Entities;

public class UserBlock
{
    public Guid Id { get; set; }
    public Guid BlockerId { get; set; }
    public Guid BlockedId { get; set; }
    public string? Reason { get; set; }
    public DateTime CreatedAt { get; set; }

    [System.Text.Json.Serialization.JsonIgnore]
    public User Blocker { get; set; } = null!;

    [System.Text.Json.Serialization.JsonIgnore]
    public User Blocked { get; set; } = null!;
}
