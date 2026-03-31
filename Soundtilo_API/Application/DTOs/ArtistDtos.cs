namespace Application.DTOs;

public class ArtistDto
{
    public Guid Id { get; set; }
    public string ExternalId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public string? ImageUrl { get; set; }
    public List<string> Tags { get; set; } = new();
    public bool IsOverride { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateArtistDto
{
    public string ExternalId { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public string? ImageUrl { get; set; }
    public List<string> Tags { get; set; } = new();
    public bool IsOverride { get; set; } = true;
}

public class UpdateArtistDto
{
    public string Name { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public string? ImageUrl { get; set; }
    public List<string> Tags { get; set; } = new();
    public bool IsOverride { get; set; } = true;
}
