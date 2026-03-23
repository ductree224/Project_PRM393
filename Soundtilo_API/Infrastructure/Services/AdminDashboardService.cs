using Application.DTOs.Admin;
using Application.Interfaces.Repositories;
using Application.Interfaces.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Services;

public class AdminDashboardService : IAdminDashboardService
{
    private const string DefaultTimeZoneId = "Asia/Ho_Chi_Minh";
    private readonly IAdminDashboardRepository _adminDashboardRepository;
    private readonly IAdminDashboardDateRangeService _dateRangeService;

    public AdminDashboardService(
        IAdminDashboardRepository adminDashboardRepository ,
        IAdminDashboardDateRangeService dateRangeService)
    {
        _adminDashboardRepository = adminDashboardRepository;
        _dateRangeService = dateRangeService;
    }

    public async Task<AdminDashboardSummaryResponse> GetSummaryAsync(CancellationToken cancellationToken = default)
    {
        return await _adminDashboardRepository.GetSummaryAsync(DefaultTimeZoneId , cancellationToken);
    }

    public async Task<AdminDashboardUserGrowthResponse> GetUserGrowthAsync(
        AdminDashboardMonthFilterRequest request ,
        CancellationToken cancellationToken = default)
    {
        var filter = _dateRangeService.ResolveMonthFilter(request.Month);

        var points = await _adminDashboardRepository.GetUserGrowthAsync(filter , cancellationToken);

        return new AdminDashboardUserGrowthResponse
        {
            Month = filter.Month ,
            TimeZone = filter.TimeZoneId ,
            RangeStartUtc = filter.RangeStartUtc ,
            RangeEndUtc = filter.RangeEndUtc ,
            Points = points
        };
    }
    /*
    public async Task<AdminDashboardPlayTrendResponse> GetPlayTrendAsync(
        AdminDashboardMonthFilterRequest request ,
        CancellationToken cancellationToken = default)
    {
        var filter = _dateRangeService.ResolveMonthFilter(request.Month);

        var points = await _adminDashboardRepository.GetPlayTrendAsync(filter , cancellationToken);

        return new AdminDashboardPlayTrendResponse
        {
            Month = filter.Month ,
            TimeZone = filter.TimeZoneId ,
            Metric = "play-count" ,
            RangeStartUtc = filter.RangeStartUtc ,
            RangeEndUtc = filter.RangeEndUtc ,
            Points = points
        };
    }*/

    public async Task<AdminDashboardPlayTrendResponse> GetPlayTrendAsync(
        AdminDashboardMonthFilterRequest request ,
        CancellationToken cancellationToken = default)
    {
        var filter = _dateRangeService.ResolveMonthFilter(request?.Month);

        var rawPoints = await _adminDashboardRepository.GetPlayTrendAsync(
            filter ,
            cancellationToken);

        var normalizedPoints = FillMissingDailyPoints(filter , rawPoints);

        return new AdminDashboardPlayTrendResponse
        {
            Month = filter.Month ,
            RangeStartUtc = filter.RangeStartUtc ,
            RangeEndUtc = filter.RangeEndUtc ,
            TimeZone = filter.TimeZoneId ,
            Metric = "play-count" ,
            Points = normalizedPoints
        };
    }

    private static IReadOnlyList<AdminDashboardDailyMetricDto> FillMissingDailyPoints(
        AdminDashboardFilterDto filter ,
        IReadOnlyList<AdminDashboardDailyMetricDto> rawPoints)
    {
        var pointMap = rawPoints.ToDictionary(
            x => x.Date ,
            x => x.Value ,
            StringComparer.Ordinal);

        var timeZone = ResolveTimeZone(filter.TimeZoneId);

        var localStartDate = TimeZoneInfo.ConvertTimeFromUtc(
            NormalizeUtc(filter.RangeStartUtc) ,
            timeZone).Date;

        var localEndExclusiveDate = TimeZoneInfo.ConvertTimeFromUtc(
            NormalizeUtc(filter.RangeEndUtc) ,
            timeZone).Date;

        var result = new List<AdminDashboardDailyMetricDto>();

        for ( var current = localStartDate; current < localEndExclusiveDate; current = current.AddDays(1) )
        {
            var key = current.ToString("yyyy-MM-dd");

            result.Add(new AdminDashboardDailyMetricDto
            {
                Date = key ,
                Value = pointMap.TryGetValue(key , out var value) ? value : 0
            });
        }

        return result;
    }

    private static DateTime NormalizeUtc(DateTime utcDateTime)
    {
        return utcDateTime.Kind == DateTimeKind.Utc
            ? utcDateTime
            : DateTime.SpecifyKind(utcDateTime , DateTimeKind.Utc);
    }

    private static TimeZoneInfo ResolveTimeZone(string timeZoneId)
    {
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
        }
        catch ( TimeZoneNotFoundException )
        {
            return TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
        }
        catch ( InvalidTimeZoneException )
        {
            return TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
        }
    }


    public async Task<AdminDashboardTopTracksResponse> GetTopTracksAsync(
        AdminDashboardTopTracksRequest request ,
        CancellationToken cancellationToken = default)
    {
        var filter = _dateRangeService.ResolveMonthFilter(request.Month);

        var limit = request.Limit ?? 10;
        if ( limit < 1 || limit > 50 )
        {
            throw new ArgumentException("Limit must be between 1 and 50.");
        }

        var items = await _adminDashboardRepository.GetTopTracksAsync(filter , limit , cancellationToken);

        return new AdminDashboardTopTracksResponse
        {
            Month = filter.Month ,
            TimeZone = filter.TimeZoneId ,
            RankingMetric = "play-count" ,
            Limit = limit ,
            RangeStartUtc = filter.RangeStartUtc ,
            RangeEndUtc = filter.RangeEndUtc ,
            Items = items
        };
    }
}
