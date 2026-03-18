namespace Domain.Entities;

public class CachedTrack
{
    public Guid Id { get; set; }
    public string ExternalId { get; set; } = string.Empty;
    public string Source { get; set; } = "audius"; // "audius" | "deezer"
    public string Title { get; set; } = string.Empty;
    public string ArtistName { get; set; } = string.Empty;
    public string? AlbumName { get; set; }
    public string? ArtworkUrl { get; set; }
    public string? StreamUrl { get; set; }
    public string? PreviewUrl { get; set; }
    public int DurationSeconds { get; set; }
    public string? Genre { get; set; }
    public string? Mood { get; set; }
    public long PlayCount { get; set; }
    public string? ExternalData { get; set; } // JSON string
    public DateTime CachedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
}
