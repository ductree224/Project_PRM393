using Application.DTOs.Admin;
using Application.Interfaces.Services;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Services;

public class AdminDashboardDateRangeService : IAdminDashboardDateRangeService
{
    private const string DefaultTimeZoneId = "Asia/Ho_Chi_Minh";

    public AdminDashboardFilterDto ResolveMonthFilter(string? month)
    {
        var timeZone = TimeZoneInfo.FindSystemTimeZoneById(DefaultTimeZoneId);

        DateTime localMonthStart;

        if ( string.IsNullOrWhiteSpace(month) )
        {
            var localNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow , timeZone);
            localMonthStart = new DateTime(localNow.Year , localNow.Month , 1 , 0 , 0 , 0 , DateTimeKind.Unspecified);
            month = $"{localMonthStart:yyyy-MM}";
        }
        else
        {
            if ( !DateTime.TryParseExact(
                    month ,
                    "yyyy-MM" ,
                    CultureInfo.InvariantCulture ,
                    DateTimeStyles.None ,
                    out var parsedMonth) )
            {
                throw new ArgumentException("Month must follow yyyy-MM format.");
            }

            localMonthStart = new DateTime(parsedMonth.Year , parsedMonth.Month , 1 , 0 , 0 , 0 , DateTimeKind.Unspecified);
        }

        var localMonthEnd = localMonthStart.AddMonths(1);

        var startUtc = TimeZoneInfo.ConvertTimeToUtc(localMonthStart , timeZone);
        var endUtc = TimeZoneInfo.ConvertTimeToUtc(localMonthEnd , timeZone);

        return new AdminDashboardFilterDto
        {
            Month = month ,
            TimeZoneId = DefaultTimeZoneId ,
            RangeStartUtc = startUtc ,
            RangeEndUtc = endUtc
        };
    }

    public (DateTime StartUtc, DateTime EndUtc) ResolveTodayRangeUtc(string timeZoneId)
    {
        var timeZone = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
        var localNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow , timeZone);

        var localStart = new DateTime(localNow.Year , localNow.Month , localNow.Day , 0 , 0 , 0 , DateTimeKind.Unspecified);
        var localEnd = localStart.AddDays(1);

        var startUtc = TimeZoneInfo.ConvertTimeToUtc(localStart , timeZone);
        var endUtc = TimeZoneInfo.ConvertTimeToUtc(localEnd , timeZone);

        return (startUtc, endUtc);
    }
}
