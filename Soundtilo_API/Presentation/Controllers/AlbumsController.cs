using Application.DTOs;
using Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AlbumsController : ControllerBase
{
    private readonly IAlbumService _albumService;

    public AlbumsController(IAlbumService albumService)
    {
        _albumService = albumService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? tag, [FromQuery] Guid? artistId)
    {
        var albums = await _albumService.GetAllAlbumsAsync(tag, artistId);
        return Ok(albums);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, [FromQuery] bool includeTracks = false)
    {
        var album = await _albumService.GetAlbumByIdAsync(id, includeTracks);
        if (album == null) return NotFound();
        return Ok(album);
    }

    [HttpGet("external/{externalId}")]
    public async Task<IActionResult> GetByExternalId(string externalId)
    {
        var album = await _albumService.GetAlbumByExternalIdAsync(externalId);
        if (album == null) return NotFound();
        return Ok(album);
    }

    [HttpPost]
    [Authorize]
    public async Task<IActionResult> Create([FromBody] CreateAlbumDto payload)
    {
        var album = await _albumService.CreateAlbumAsync(payload);
        return CreatedAtAction(nameof(GetById), new { id = album.Id }, album);
    }

    [HttpPut("{id:guid}")]
    [Authorize]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateAlbumDto payload)
    {
        try
        {
            await _albumService.UpdateAlbumAsync(id, payload);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:guid}")]
    [Authorize]
    public async Task<IActionResult> Delete(Guid id)
    {
        try
        {
            await _albumService.DeleteAlbumAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpPost("{id:guid}/tracks")]
    [Authorize]
    public async Task<IActionResult> AddTrack(Guid id, [FromBody] AddTrackToAlbumDto payload)
    {
        try
        {
            await _albumService.AddTrackToAlbumAsync(id, payload);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    [HttpDelete("{id:guid}/tracks/{trackExternalId}")]
    [Authorize]
    public async Task<IActionResult> RemoveTrack(Guid id, string trackExternalId)
    {
        await _albumService.RemoveTrackFromAlbumAsync(id, trackExternalId);
        return NoContent();
    }
}
