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

    /// <summary>GET /api/admin/subscriptions/stats — summary (active, expiring soon, revenue)</summary>
    [HttpGet("stats")]
    public async Task<IActionResult> GetStats()
    {
        var result = await _subscriptionService.GetSubscriptionStatsAsync();
        return Ok(result);
    }

    /// <summary>GET /api/admin/subscriptions/expiring?daysAhead=10&amp;page=1&amp;pageSize=20</summary>
    [HttpGet("expiring")]
    public async Task<IActionResult> GetExpiring(
        [FromQuery] int daysAhead = 10,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        var result = await _subscriptionService.GetExpiringSubscriptionsAsync(daysAhead, page, pageSize);
        return Ok(result);
    }

    /// <summary>GET /api/admin/subscriptions/{id} — single subscription detail</summary>
    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetSubscriptionById(Guid id)
    {
        var result = await _subscriptionService.GetSubscriptionByIdAsync(id);
        if (result is null) return NotFound(new { message = "Subscription not found." });
        return Ok(result);
    }
}
