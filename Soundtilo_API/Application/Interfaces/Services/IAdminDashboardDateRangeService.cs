using Application.DTOs.Admin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces.Services;

public interface IAdminDashboardDateRangeService
{
    AdminDashboardFilterDto ResolveMonthFilter(string? month);
    (DateTime StartUtc, DateTime EndUtc) ResolveTodayRangeUtc(string timeZoneId);
}
