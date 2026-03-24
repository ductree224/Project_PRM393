using Domain.Enums;

namespace Application.DTOs;

public class TrackAdminDto
{
    public string ExternalId { get; set; } = string.Empty;
    public string Source { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string ArtistName { get; set; } = string.Empty;
    public string? AlbumName { get; set; }
    public string? ArtworkUrl { get; set; }
    public string? Status { get; set; } // "Active", "Inactive", "Hidden"
    public DateTime CachedAt { get; set; }
}

public class UpdateTrackStatusDto
{
    public List<string> ExternalIds { get; set; } = new();
    public TrackStatus Status { get; set; }
}

public class BulkAddTracksToAlbumDto
{
    public Guid AlbumId { get; set; }
    public List<string> TrackExternalIds { get; set; } = new();
}
