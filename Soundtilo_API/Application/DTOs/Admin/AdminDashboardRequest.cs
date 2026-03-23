using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Admin;

internal class AdminDashboardRequest
{
}

public sealed class AdminDashboardMonthFilterRequest
{
    public string? Month { get; set; } // yyyy-MM
}

public sealed class AdminDashboardTopTracksRequest
{
    public string? Month { get; set; } // yyyy-MM
    public int? Limit { get; set; }
}

