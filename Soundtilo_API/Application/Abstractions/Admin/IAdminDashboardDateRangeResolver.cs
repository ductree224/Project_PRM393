using Application.DTOs.Admin;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Abstractions.Admin;

public interface IAdminDashboardDateRangeResolver
{
    AdminDashboardFilterDto ResolveMonth(string? month);
    (DateTime StartUtc, DateTime EndUtc) ResolveToday(string timeZoneId);
}
