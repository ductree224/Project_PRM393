using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/admin/subscriptions")]
[Authorize(Roles = "admin")]
public class SubscriptionsController : ControllerBase
{
    private readonly SubscriptionService _subscriptionService;

    public SubscriptionsController(SubscriptionService subscriptionService)
    {
        _subscriptionService = subscriptionService;
    }

    /// <summary>GET /api/admin/subscriptions?page=1&amp;pageSize=20&amp;status=active</summary>
    [HttpGet]
    public async Task<IActionResult> GetSubscriptions(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] string? status = null)
    {
        var result = await _subscriptionService.GetSubscriptionsAsync(page, pageSize, status);
        return Ok(result);
    }

    /// <summary>GET /api/admin/subscriptions/transactions?page=1&amp;pageSize=20&amp;userId=</summary>
    [HttpGet("transactions")]
    public async Task<IActionResult> GetTransactions(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] Guid? userId = null)
    {
        var result = await _subscriptionService.GetTransactionsAsync(page, pageSize, userId);
        return Ok(result);
    }
}
