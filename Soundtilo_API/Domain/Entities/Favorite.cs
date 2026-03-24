namespace Domain.Entities;

public class Favorite
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string TrackExternalId { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    // Navigation properties
    [System.Text.Json.Serialization.JsonIgnore]
    public User User { get; set; } = null!;
}
