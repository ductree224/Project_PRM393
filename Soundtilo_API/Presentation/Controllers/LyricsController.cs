using Application.Services;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/[controller]")]
public class LyricsController : ControllerBase
{
    private readonly LyricsService _lyricsService;

    public LyricsController(LyricsService lyricsService)
    {
        _lyricsService = lyricsService;
    }

    [HttpGet]
    public async Task<IActionResult> GetLyrics([FromQuery] string artist, [FromQuery] string title)
    {
        if (string.IsNullOrWhiteSpace(artist) || string.IsNullOrWhiteSpace(title))
            return BadRequest(new { message = "Vui lòng cung cấp tên nghệ sĩ và tên bài hát." });

        var result = await _lyricsService.GetLyricsAsync(artist, title);
        return Ok(result);
    }
}
