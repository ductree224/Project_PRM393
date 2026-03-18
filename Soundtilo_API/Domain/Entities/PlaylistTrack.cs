namespace Domain.Entities;

public class PlaylistTrack
{
    public Guid Id { get; set; }
    public Guid PlaylistId { get; set; }
    public string TrackExternalId { get; set; } = string.Empty;
    public int Position { get; set; }
    public DateTime AddedAt { get; set; }

    // Navigation properties
    public Playlist Playlist { get; set; } = null!;
}
