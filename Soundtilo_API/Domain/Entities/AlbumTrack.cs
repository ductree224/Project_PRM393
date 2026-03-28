using System.Text.Json.Serialization;

namespace Domain.Entities;

public class AlbumTrack
{
    public Guid Id { get; set; }
    public Guid AlbumId { get; set; }
    public string TrackExternalId { get; set; } = string.Empty;
    public int Position { get; set; }
    public DateTime AddedAt { get; set; }

    // Navigation properties
    [JsonIgnore]
    public Album Album { get; set; } = null!;
}
