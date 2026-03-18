using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Application.DTOs.Playlists;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PlaylistsController : ControllerBase
{
    private readonly PlaylistService _playlistService;

    public PlaylistsController(PlaylistService playlistService)
    {
        _playlistService = playlistService;
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException());

    [HttpGet]
    public async Task<IActionResult> GetMyPlaylists()
    {
        var userId = GetUserId();
        var playlists = await _playlistService.GetUserPlaylistsAsync(userId);
        return Ok(playlists);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetPlaylist(Guid id)
    {
        var userId = GetUserId();
        try
        {
            var playlist = await _playlistService.GetPlaylistDetailAsync(id, userId);
            if (playlist == null)
                return NotFound(new { message = "Playlist không tồn tại." });
            return Ok(playlist);
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
    }

    [HttpPost]
    public async Task<IActionResult> CreatePlaylist([FromBody] CreatePlaylistRequest request)
    {
        var userId = GetUserId();
        var playlist = await _playlistService.CreatePlaylistAsync(userId, request);
        return CreatedAtAction(nameof(GetPlaylist), new { id = playlist.Id }, playlist);
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> UpdatePlaylist(Guid id, [FromBody] UpdatePlaylistRequest request)
    {
        var userId = GetUserId();
        try
        {
            var playlist = await _playlistService.UpdatePlaylistAsync(id, userId, request);
            if (playlist == null)
                return NotFound(new { message = "Playlist không tồn tại." });
            return Ok(playlist);
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletePlaylist(Guid id)
    {
        var userId = GetUserId();
        try
        {
            await _playlistService.DeletePlaylistAsync(id, userId);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
    }

    [HttpPost("{id}/tracks")]
    public async Task<IActionResult> AddTrack(Guid id, [FromBody] AddTrackToPlaylistRequest request)
    {
        var userId = GetUserId();
        try
        {
            await _playlistService.AddTrackAsync(id, userId, request);
            return Ok(new { message = "Đã thêm bài hát vào playlist." });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
    }

    [HttpDelete("{id}/tracks/{trackExternalId}")]
    public async Task<IActionResult> RemoveTrack(Guid id, string trackExternalId)
    {
        var userId = GetUserId();
        try
        {
            await _playlistService.RemoveTrackAsync(id, userId, trackExternalId);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
    }

    [HttpPut("{id}/tracks/reorder")]
    public async Task<IActionResult> ReorderTracks(Guid id, [FromBody] ReorderTracksRequest request)
    {
        var userId = GetUserId();
        try
        {
            await _playlistService.ReorderTracksAsync(id, userId, request);
            return Ok(new { message = "Đã sắp xếp lại playlist." });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
    }
}
