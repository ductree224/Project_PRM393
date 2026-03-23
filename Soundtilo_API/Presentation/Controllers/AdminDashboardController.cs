using Application.DTOs.Admin;
using Application.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/admin/dashboard")]
public class AdminDashboardController : ControllerBase
{
    private readonly IAdminDashboardService _adminDashboardService;

    public AdminDashboardController(IAdminDashboardService adminDashboardService)
    {
        _adminDashboardService = adminDashboardService;
    }

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary(CancellationToken cancellationToken)
    {
        var response = await _adminDashboardService.GetSummaryAsync(cancellationToken);
        return Ok(response);
    }

    [HttpGet("user-growth")]
    public async Task<IActionResult> GetUserGrowth(
        [FromQuery] AdminDashboardMonthFilterRequest request ,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _adminDashboardService.GetUserGrowthAsync(request , cancellationToken);
            return Ok(response);
        }
        catch ( ArgumentException ex )
        {
            return ToBadRequest(ex);
        }
    }

    [HttpGet("play-trend")]
    public async Task<IActionResult> GetPlayTrend(
        [FromQuery] AdminDashboardMonthFilterRequest request ,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _adminDashboardService.GetPlayTrendAsync(request , cancellationToken);
            return Ok(response);
        }
        catch ( ArgumentException ex )
        {
            return ToBadRequest(ex);
        }
    }

    [HttpGet("top-tracks")]
    public async Task<IActionResult> GetTopTracks(
        [FromQuery] AdminDashboardTopTracksRequest request ,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _adminDashboardService.GetTopTracksAsync(request , cancellationToken);
            return Ok(response);
        }
        catch ( ArgumentException ex )
        {
            return ToBadRequest(ex);
        }
    }

    private IActionResult ToBadRequest(ArgumentException ex)
    {
        var title = ex.Message.Contains("Month" , StringComparison.OrdinalIgnoreCase)
            ? "Invalid month format."
            : ex.Message.Contains("Limit" , StringComparison.OrdinalIgnoreCase)
                ? "Invalid limit."
                : "Invalid request.";

        return BadRequest(new ProblemDetails
        {
            Title = title ,
            Detail = ex.Message ,
            Status = StatusCodes.Status400BadRequest
        });
    }
}

