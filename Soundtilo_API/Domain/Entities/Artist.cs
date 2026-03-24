namespace Domain.Entities;

public class Artist
{
    public Guid Id { get; set; }
    public string ExternalId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public string? ImageUrl { get; set; }
    public List<string> Tags { get; set; } = new();
    
    /// <summary>
    /// If true, this record is maintained by local admins and should 
    /// override or take precedence over data synced from external APIs.
    /// </summary>
    public bool IsOverride { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    // Navigation properties
    public ICollection<Album> Albums { get; set; } = new List<Album>();
}
