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
