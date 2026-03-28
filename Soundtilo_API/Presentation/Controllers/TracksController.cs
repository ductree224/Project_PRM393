using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using Application.Interfaces;
using Application.DTOs.Tracks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TracksController : ControllerBase
{
    private readonly ITrackService _trackService;

    public TracksController(ITrackService trackService)
    {
        _trackService = trackService;
    }

    [HttpGet("search")]
    [AllowAnonymous]
    public async Task<IActionResult> Search(
        [FromQuery] string q,
        [FromQuery] string? source = null,
        [FromQuery] int limit = 20,
        [FromQuery] int offset = 0,
        [FromQuery] bool cacheOnly = false,
        [FromQuery] bool fallbackExternal = true)
    {
        if (string.IsNullOrWhiteSpace(q))
            return BadRequest(new { message = "Vui lòng nhập từ khóa tìm kiếm." });

        var safeLimit = Math.Clamp(limit, 1, 50);
        var safeOffset = Math.Max(offset, 0);

        var result = await _trackService.SearchAsync(
            q,
            source,
            safeLimit,
            safeOffset,
            cacheOnly,
            fallbackExternal);
        return Ok(result);
    }

    [HttpGet("trending")]
    [AllowAnonymous]
    public async Task<IActionResult> GetTrending(
        [FromQuery] string? genre = null,
        [FromQuery] string? time = null,
        [FromQuery] int limit = 20,
        [FromQuery] int offset = 0)
    {
        var safeLimit = Math.Clamp(limit, 1, 50);
        var safeOffset = Math.Max(offset, 0);

        var result = await _trackService.GetTrendingAsync(genre, time, safeLimit, safeOffset);
        return Ok(result);
    }

    [HttpGet("{id}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetTrack(string id, [FromQuery] string source = "audius")
    {
        var result = await _trackService.GetTrackAsync(id, source);
        if (result == null)
            return NotFound(new { message = "Không tìm thấy bài hát." });

        return Ok(result);
    }

    [HttpGet("{id}/stream")]
    [AllowAnonymous]
    public async Task<IActionResult> GetStreamUrl(string id)
    {
        var url = await _trackService.GetStreamUrlAsync(id);
        if (url == null)
            return NotFound(new { message = "Không tìm thấy link phát nhạc." });

        return Ok(new { streamUrl = url });
    }

    /// <summary>
    /// Browse tracks by tag/genre (Jamendo CC-licensed music).
    /// Example tags: pop, rock, electronic, jazz, hiphop, classical, ambient
    /// </summary>
    [HttpGet("tags/{tag}")]
    [AllowAnonymous]
    public async Task<IActionResult> GetByTag(string tag, [FromQuery] int limit = 20)
    {
        var result = await _trackService.GetByTagAsync(tag, limit);
        return Ok(result);
    }
}
