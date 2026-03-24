namespace Domain.Entities;

public class Album
{
    public Guid Id { get; set; }
    public string ExternalId { get; set; } = string.Empty;
    public Guid? ArtistId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime? ReleaseDate { get; set; }
    public string? CoverImageUrl { get; set; }
    public List<string> Tags { get; set; } = new();
    
    /// <summary>
    /// If true, this record is maintained by local admins and should 
    /// override or take precedence over data synced from external APIs.
    /// </summary>
    public bool IsOverride { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    // Navigation properties
    [System.Text.Json.Serialization.JsonIgnore]
    public Artist? Artist { get; set; }
}
