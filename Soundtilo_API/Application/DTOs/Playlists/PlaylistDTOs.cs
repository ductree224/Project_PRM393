namespace Application.DTOs.Playlists;

public record PlaylistDto(
    Guid Id,
    string Name,
    string? Description,
    string? CoverImageUrl,
    bool IsPublic,
    int TrackCount,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public record PlaylistDetailDto(
    Guid Id,
    string Name,
    string? Description,
    string? CoverImageUrl,
    bool IsPublic,
    IEnumerable<PlaylistTrackDto> Tracks,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public record PlaylistTrackDto(
    string TrackExternalId,
    int Position,
    DateTime AddedAt
);

public record CreatePlaylistRequest(
    string Name,
    string? Description,
    bool IsPublic = false
);

public record UpdatePlaylistRequest(
    string? Name,
    string? Description,
    bool? IsPublic
);

public record AddTrackToPlaylistRequest(
    string TrackExternalId
);

public record ReorderTracksRequest(
    List<string> TrackExternalIds
);
