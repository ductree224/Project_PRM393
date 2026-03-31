namespace Domain.Entities;

public class ListeningHistory
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public string TrackExternalId { get; set; } = string.Empty;
    public DateTime ListenedAt { get; set; }
    public int DurationListened { get; set; }
    public bool Completed { get; set; }

    // Navigation properties
    [System.Text.Json.Serialization.JsonIgnore]
    public User User { get; set; } = null!;
}
