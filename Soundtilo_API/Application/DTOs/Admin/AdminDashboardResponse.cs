using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Admin;

internal class AdminDashboardResponse
{
}

public sealed class AdminDashboardSummaryResponse
{
    public long TotalUsers { get; init; }
    public long TotalPlayCount { get; init; }
    public long NewUsersToday { get; init; }
    public long CachedTracks { get; init; }

    public AdminDashboardSummaryMetaDto Meta { get; init; } = new();
}

public sealed class AdminDashboardSummaryMetaDto
{
    public string TimeZone { get; init; } = "Asia/Ho_Chi_Minh";
    public string TotalPlayCountScope { get; init; } = "all-time";
    public string CachedTracksScope { get; init; } = "active-only";
    public DateTime GeneratedAtUtc { get; init; }
}

public sealed class AdminDashboardUserGrowthResponse
{
    public string? Month { get; init; }
    public DateTime RangeStartUtc { get; init; }
    public DateTime RangeEndUtc { get; init; }
    public string TimeZone { get; init; } = "Asia/Ho_Chi_Minh";
    //public IReadOnlyList<AdminDashboardDailyMetricDto> Points { get; init; } = [];
    public IReadOnlyList<AdminDashboardDailyMetricDto> Points { get; set; } = new List<AdminDashboardDailyMetricDto>();
}

public sealed class AdminDashboardPlayTrendResponse
{
    public string? Month { get; init; }
    public DateTime RangeStartUtc { get; init; }
    public DateTime RangeEndUtc { get; init; }
    public string TimeZone { get; init; } = "Asia/Ho_Chi_Minh";
    public string Metric { get; init; } = "play-count";
    public IReadOnlyList<AdminDashboardDailyMetricDto> Points { get; set; } = new List<AdminDashboardDailyMetricDto>();
}

public sealed class AdminDashboardTopTracksResponse
{
    public string? Month { get; init; }
    public DateTime RangeStartUtc { get; init; }
    public DateTime RangeEndUtc { get; init; }
    public string TimeZone { get; init; } = "Asia/Ho_Chi_Minh";
    public int Limit { get; init; }
    public string RankingMetric { get; init; } = "play-count";
    public IReadOnlyList<AdminDashboardTopTrackItemDto> Items { get; set; } = new List<AdminDashboardTopTrackItemDto>();
}
