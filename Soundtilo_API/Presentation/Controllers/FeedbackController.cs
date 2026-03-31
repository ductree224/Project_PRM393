using Application.DTOs.Feedbacks;
using Application.Interfaces.Services;
using Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace Presentation.Controllers;

[Authorize]
[ApiController]
//[Route("api/v1/feedbacks")]
[Route("api/feedbacks")]
public class FeedbackController : ControllerBase
{
    private readonly IFeedbackService _service;
    private readonly IFeedbackAnalyticsService _analyticsService;

    public FeedbackController(IFeedbackService service ,
                              IFeedbackAnalyticsService analyticsService)
    {
        _service = service;
        _analyticsService = analyticsService;
    }

    [HttpPost]
    public async Task<IActionResult> Create(CreateFeedbackDto dto)
    {
        var userId = GetUserId();

        await _service.CreateAsync(userId , dto);
        return Ok();
    }

    // USER VIEW OWN FEEDBACK
    [HttpGet("me")]
    public async Task<IActionResult> My(
        [FromQuery] string? status ,
        [FromQuery] int page = 1 ,
        [FromQuery] int pageSize = 10)
    {
        var userId = GetUserId();

        var data = await _service.GetMyFeedbacks(userId , status , page , pageSize);
        return Ok(data);
    }

    // ADMIN FILTER + PAGINATION
    [Authorize(Roles = "admin")]
    [HttpGet]
    public async Task<IActionResult> AdminGet(
        [FromQuery] string? status ,
        [FromQuery] string? category ,
        [FromQuery] int page = 1 ,
        [FromQuery] int pageSize = 10)
    {
        var data = await _service.AdminGetAsync(status , category , page , pageSize);
        return Ok(data);
    }

    [Authorize(Roles = "admin")]
    [HttpPut("{id}/handle")]
    public async Task<IActionResult> Handle(Guid id , HandleFeedbackRequest req)
    {
        var adminId = GetUserId();

        await _service.HandleAsync(id , req.Reply , req.Status , adminId);
        return Ok();
    }

    [HttpGet("analytics")]
    public async Task<IActionResult> GetAnalytics([FromQuery] int days = 7)
    {
        var data = await _analyticsService.GetDashboardAsync(days);
        return Ok(data);
    }

    //  helper for auth
    private Guid GetUserId()
    {
        var userIdClaim = User.FindFirst("sub")?.Value
            ?? User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        if ( !Guid.TryParse(userIdClaim , out var userId) )
            throw new UnauthorizedAccessException("Invalid or missing user id");

        return userId;
    }
}

public class HandleFeedbackRequest
{
    public string Reply { get; set; } = string.Empty;
    public string Status { get; set; } = "in_progress";
}

