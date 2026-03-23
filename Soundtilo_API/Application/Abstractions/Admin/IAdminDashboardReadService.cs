using Application.DTOs.Admin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Abstractions.Admin;

public interface IAdminDashboardReadService
{
    Task<AdminDashboardSummaryResponse> GetSummaryAsync(CancellationToken cancellationToken = default);
    Task<AdminDashboardUserGrowthResponse> GetUserGrowthAsync(AdminDashboardFilterDto filter , CancellationToken cancellationToken = default);
    Task<AdminDashboardPlayTrendResponse> GetPlayTrendAsync(AdminDashboardFilterDto filter , CancellationToken cancellationToken = default);
    Task<AdminDashboardTopTracksResponse> GetTopTracksAsync(AdminDashboardFilterDto filter , int limit , CancellationToken cancellationToken = default);
}
