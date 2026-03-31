using Application.DTOs.Tracks;

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
    public ArtistDto? Artist { get; set; }
    public List<AlbumTrackDto> Tracks { get; set; } = new();
}

public class AlbumTrackDto
{
    public Guid Id { get; set; }
    public string TrackExternalId { get; set; } = string.Empty;
    public int Position { get; set; }
    public DateTime AddedAt { get; set; }
    public TrackDto? Track { get; set; }
}

public class AddTrackToAlbumDto
{
    public string TrackExternalId { get; set; } = string.Empty;
    public int Position { get; set; }
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
