using Application.DTOs;
using Application.Interfaces;
using Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/admin/tracks")]
[Authorize] // Should ideally be [Authorize(Roles = "Admin")] if roles are implemented
public class AdminTracksController : ControllerBase
{
    private readonly ITrackService _trackService;

    public AdminTracksController(ITrackService trackService)
    {
        _trackService = trackService;
    }

    [HttpGet]
    public async Task<IActionResult> GetTracks([FromQuery] TrackStatus? status, [FromQuery] string? q, [FromQuery] int limit = 50, [FromQuery] int offset = 0)
    {
        var tracks = await _trackService.GetTracksAsync(status, q, limit, offset);
        return Ok(tracks);
    }

    [HttpPatch("status")]
    public async Task<IActionResult> UpdateStatus([FromBody] UpdateTrackStatusDto payload)
    {
        if (payload.ExternalIds == null || !payload.ExternalIds.Any())
            return BadRequest(new { message = "No tracks selected." });

        await _trackService.UpdateStatusesAsync(payload);
        return NoContent();
    }
}
