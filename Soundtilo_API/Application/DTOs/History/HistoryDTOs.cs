namespace Application.DTOs.History;

public record HistoryDto(
    Guid Id,
    string TrackExternalId,
    DateTime ListenedAt,
    int DurationListened,
    bool Completed
);

public record HistoryListResponse(
    IEnumerable<HistoryDto> History,
    int TotalListens,
    int TotalListeningTimeSeconds
);

public record RecordListenRequest(
    string TrackExternalId,
    int DurationListened,
    bool Completed
);

public record DeleteHistoryRequest(
    IReadOnlyCollection<Guid> HistoryIds
);

public record DeleteHistoryResponse(
    int DeletedCount
);
