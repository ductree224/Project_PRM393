namespace Application.DTOs;

public class AlbumDto
{
    public Guid Id { get; set; }
    public string ExternalId { get; set; } = string.Empty;
    public Guid? ArtistId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime? ReleaseDate { get; set; }
    public string? CoverImageUrl { get; set; }
    public List<string> Tags { get; set; } = new();
    public bool IsOverride { get; set; }
    public DateTime CreatedAt { get; set; }
}

public class CreateAlbumDto
{
    public string ExternalId { get; set; } = string.Empty;
    public Guid? ArtistId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime? ReleaseDate { get; set; }
    public string? CoverImageUrl { get; set; }
    public List<string> Tags { get; set; } = new();
    public bool IsOverride { get; set; } = true;
}

public class UpdateAlbumDto
{
    public Guid? ArtistId { get; set; }
    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime? ReleaseDate { get; set; }
    public string? CoverImageUrl { get; set; }
    public List<string> Tags { get; set; } = new();
    public bool IsOverride { get; set; } = true;
}
