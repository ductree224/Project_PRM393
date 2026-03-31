using Application.DTOs.Feedbacks;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces.Services;

public interface IFeedbackAnalyticsService
{
    Task<FeedbackAnalyticsDto> GetDashboardAsync(int days = 7);
}
