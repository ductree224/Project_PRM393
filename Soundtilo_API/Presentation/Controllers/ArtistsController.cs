using Application.DTOs;
using Application.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[Route("api/[controller]")]
[ApiController]
public class ArtistsController : ControllerBase
{
    private readonly IArtistService _artistService;

    public ArtistsController(IArtistService artistService)
    {
        _artistService = artistService;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? tag)
    {
        var artists = await _artistService.GetAllArtistsAsync(tag);
        return Ok(artists);
    }

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var artist = await _artistService.GetArtistByIdAsync(id);
        if (artist == null) return NotFound();
        return Ok(artist);
    }

    [HttpGet("external/{externalId}")]
    public async Task<IActionResult> GetByExternalId(string externalId)
    {
        var artist = await _artistService.GetArtistByExternalIdAsync(externalId);
        if (artist == null) return NotFound();
        return Ok(artist);
    }

    [HttpPost]
    [Authorize]
    public async Task<IActionResult> Create([FromBody] CreateArtistDto payload)
    {
        var artist = await _artistService.CreateArtistAsync(payload);
        return CreatedAtAction(nameof(GetById), new { id = artist.Id }, artist);
    }

    [HttpPut("{id:guid}")]
    [Authorize]
    public async Task<IActionResult> Update(Guid id, [FromBody] UpdateArtistDto payload)
    {
        try
        {
            await _artistService.UpdateArtistAsync(id, payload);
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
            await _artistService.DeleteArtistAsync(id);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }
}
