using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Application.DTOs.Favorites;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class FavoritesController : ControllerBase
{
    private readonly FavoriteService _favoriteService;

    public FavoritesController(FavoriteService favoriteService)
    {
        _favoriteService = favoriteService;
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException());

    [HttpGet]
    public async Task<IActionResult> GetFavorites([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var userId = GetUserId();
        var result = await _favoriteService.GetFavoritesAsync(userId, page, pageSize);
        return Ok(result);
    }

    [HttpPost("{trackExternalId}")]
    public async Task<IActionResult> ToggleFavorite(string trackExternalId)
    {
        var userId = GetUserId();
        var result = await _favoriteService.ToggleFavoriteAsync(userId, trackExternalId);
        return Ok(result);
    }

    [HttpGet("{trackExternalId}/check")]
    public async Task<IActionResult> CheckFavorite(string trackExternalId)
    {
        var userId = GetUserId();
        var isFavorite = await _favoriteService.IsFavoriteAsync(userId, trackExternalId);
        return Ok(new { isFavorite });
    }
}
