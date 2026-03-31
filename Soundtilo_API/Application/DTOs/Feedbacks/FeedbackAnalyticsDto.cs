using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Feedbacks;

public class FeedbackAnalyticsDto
{
    public int Total { get; set; }
    public int Resolved { get; set; }
    public double ResolvedRate { get; set; }

    public List<DailyFeedbackDto> Daily { get; set; } = [];
    public List<CategoryStatsDto> Categories { get; set; } = [];
}

public class DailyFeedbackDto
{
    public DateOnly Date { get; set; }
    public int Count { get; set; }
}

public class CategoryStatsDto
{
    public string Category { get; set; } = "";
    public int Count { get; set; }
}