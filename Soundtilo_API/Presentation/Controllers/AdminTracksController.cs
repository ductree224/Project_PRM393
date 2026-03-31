using Application.DTOs;
using Application.Interfaces;
using Domain.Enums;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/admin/tracks")]
[Authorize(Roles = "admin")]
public class AdminTracksController : ControllerBase
{
    private readonly ITrackService _trackService;

    public AdminTracksController(ITrackService trackService)
    {
        _trackService = trackService;
    }

    private Guid GetAdminId() =>
        Guid.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException());

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

        await _trackService.UpdateStatusesAsync(payload, GetAdminId());
        return NoContent();
    }

    [HttpPost("add-to-album")]
    public async Task<IActionResult> BulkAddTracksToAlbum([FromBody] BulkAddTracksToAlbumDto payload)
    {
        if (payload.TrackExternalIds == null || !payload.TrackExternalIds.Any())
            return BadRequest(new { message = "No tracks selected." });

        if (payload.AlbumId == Guid.Empty)
            return BadRequest(new { message = "No album selected." });

        await _trackService.BulkAddTracksToAlbumAsync(payload);
        return Ok(new { message = "Tracks added to album successfully." });
    }
}
