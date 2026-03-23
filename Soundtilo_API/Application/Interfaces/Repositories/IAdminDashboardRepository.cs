using Application.DTOs.Admin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces.Repositories;

public interface IAdminDashboardRepository
{
    Task<AdminDashboardSummaryResponse> GetSummaryAsync(
        string timeZoneId ,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<AdminDashboardDailyMetricDto>> GetUserGrowthAsync(
        AdminDashboardFilterDto filter ,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<AdminDashboardDailyMetricDto>> GetPlayTrendAsync(
        AdminDashboardFilterDto filter ,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<AdminDashboardTopTrackItemDto>> GetTopTracksAsync(
        AdminDashboardFilterDto filter ,
        int limit ,
        CancellationToken cancellationToken = default);
}
