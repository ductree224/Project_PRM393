using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Admin;

internal class AdminDashboardDtos
{
}

public sealed class AdminDashboardFilterDto
{
    public string? Month { get; init; }
    public DateTime RangeStartUtc { get; init; }
    public DateTime RangeEndUtc { get; init; }
    public string TimeZoneId { get; init; } = "Asia/Ho_Chi_Minh";
}

public sealed class AdminDashboardDailyMetricDto
{
    public string Date { get; init; } = string.Empty;
    public long Value { get; init; }
}

public sealed class AdminDashboardTopTrackItemDto
{
    public string TrackExternalId { get; init; } = string.Empty;
    public string? Title { get; init; }
    public string? ArtistName { get; init; }
    public string? ArtworkUrl { get; init; }
    public int? DurationSeconds { get; init; }

    public long PlayCount { get; init; }
    public long TotalDurationListened { get; init; }
}

