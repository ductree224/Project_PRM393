using Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

/// <summary>
/// Public endpoint — no authentication required.
/// Returns active subscription plans so the Flutter app can display
/// the paywall with live pricing without hardcoding values.
/// </summary>
[ApiController]
[Route("api/subscriptions")]
public class SubscriptionPlansController : ControllerBase
{
    private readonly SubscriptionService _subscriptionService;

    public SubscriptionPlansController(SubscriptionService subscriptionService)
    {
        _subscriptionService = subscriptionService;
    }

    /// <summary>GET /api/subscriptions/plans — returns all active plans (free, monthly, yearly)</summary>
    [HttpGet("plans")]
    public async Task<IActionResult> GetPlans()
    {
        var result = await _subscriptionService.GetPlansAsync();
        return Ok(result);
    }
}
