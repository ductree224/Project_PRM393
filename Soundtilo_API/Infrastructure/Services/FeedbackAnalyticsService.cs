using Application.DTOs.Feedbacks;
using Application.Interfaces.Services;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Services;

public class FeedbackAnalyticsService : IFeedbackAnalyticsService
{
    private readonly SoundtiloDbContext _context;

    public FeedbackAnalyticsService(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<FeedbackAnalyticsDto> GetDashboardAsync(int days = 7)
    {
        var fromDate = DateTime.UtcNow.AddDays(-days);

        var query = _context.Feedbacks
            .Where(x => x.CreatedAt >= fromDate);

        var total = await query.CountAsync();
        var resolved = await query.CountAsync(x => x.Status == "resolved");

        var daily = await query
            .GroupBy(x => DateOnly.FromDateTime(x.CreatedAt))
            .Select(g => new DailyFeedbackDto
            {
                Date = g.Key ,
                Count = g.Count()
            })
            .OrderBy(x => x.Date)
            .ToListAsync();

        var categories = await query
            .GroupBy(x => x.Category)
            .Select(g => new CategoryStatsDto
            {
                Category = g.Key ,
                Count = g.Count()
            })
            .ToListAsync();

        return new FeedbackAnalyticsDto
        {
            Total = total ,
            Resolved = resolved ,
            ResolvedRate = total == 0 ? 0 : (double) resolved / total ,
            Daily = daily ,
            Categories = categories
        };
    }
}
