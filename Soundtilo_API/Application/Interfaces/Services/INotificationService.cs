using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces.Services;

public interface INotificationService
{
    Task NotifyAdminNewFeedbackAsync(Feedback feedback , CancellationToken ct = default);

    Task NotifyUserFeedbackHandledAsync(Feedback feedback , CancellationToken ct = default);
    Task<int> CleanupExpiredNotificationsAsync(CancellationToken ct = default);
}