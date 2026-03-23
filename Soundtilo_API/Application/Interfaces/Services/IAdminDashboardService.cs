using Application.DTOs.Admin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces.Services;

public interface IAdminDashboardService
{
    Task<AdminDashboardSummaryResponse> GetSummaryAsync(CancellationToken cancellationToken = default);

    Task<AdminDashboardUserGrowthResponse> GetUserGrowthAsync(
        AdminDashboardMonthFilterRequest request ,
        CancellationToken cancellationToken = default);

    Task<AdminDashboardPlayTrendResponse> GetPlayTrendAsync(
        AdminDashboardMonthFilterRequest request ,
        CancellationToken cancellationToken = default);

    Task<AdminDashboardTopTracksResponse> GetTopTracksAsync(
        AdminDashboardTopTracksRequest request ,
        CancellationToken cancellationToken = default);
}
