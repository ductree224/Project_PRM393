namespace Application.DTOs.Tracks;

public record TrackDto(
    string ExternalId,
    string Source,
    string Title,
    string ArtistName,
    string? AlbumName,
    string? ArtworkUrl,
    string? StreamUrl,
    string? PreviewUrl,
    int DurationSeconds,
    string? Genre,
    string? Mood,
    long PlayCount
);

public record TrackSearchResponse(
    IEnumerable<TrackDto> Tracks,
    int TotalCount
);

public record TrendingResponse(
    IEnumerable<TrackDto> Tracks
);
