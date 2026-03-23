using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Application.DTOs.Admin;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "admin")]
public class AdminController : ControllerBase
{
    private readonly AdminService _adminService;

    public AdminController(AdminService adminService)
    {
        _adminService = adminService;
    }

    private Guid GetAdminId() =>
        Guid.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException());

    // ─── User Management ──────────────────────────────────────────────────────

    /// <summary>GET /api/admin/users?page=1&amp;pageSize=20&amp;search=&amp;role=&amp;isBanned=</summary>
    [HttpGet("users")]
    public async Task<IActionResult> GetUsers(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20,
        [FromQuery] string? search = null,
        [FromQuery] string? role = null,
        [FromQuery] bool? isBanned = null)
    {
        var result = await _adminService.GetUsersAsync(page, pageSize, search, role, isBanned);
        return Ok(result);
    }

    /// <summary>GET /api/admin/users/{id}</summary>
    [HttpGet("users/{id:guid}")]
    public async Task<IActionResult> GetUserDetail(Guid id)
    {
        try
        {
            var detail = await _adminService.GetUserDetailAsync(id);
            return Ok(detail);
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }
    }

    /// <summary>GET /api/admin/users/{id}/history?page=1&amp;pageSize=20</summary>
    [HttpGet("users/{id:guid}/history")]
    public async Task<IActionResult> GetUserHistory(
        Guid id,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        try
        {
            var result = await _adminService.GetUserHistoryAsync(id, page, pageSize);
            return Ok(result);
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }
    }

    /// <summary>GET /api/admin/users/{id}/favorites?page=1&amp;pageSize=20</summary>
    [HttpGet("users/{id:guid}/favorites")]
    public async Task<IActionResult> GetUserFavorites(
        Guid id,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        try
        {
            var result = await _adminService.GetUserFavoritesAsync(id, page, pageSize);
            return Ok(result);
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }
    }

    /// <summary>GET /api/admin/users/{id}/playlists?page=1&amp;pageSize=20</summary>
    [HttpGet("users/{id:guid}/playlists")]
    public async Task<IActionResult> GetUserPlaylists(
        Guid id,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 20)
    {
        try
        {
            var result = await _adminService.GetUserPlaylistsAsync(id, page, pageSize);
            return Ok(result);
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }
    }

    /// <summary>POST /api/admin/users/{id}/ban</summary>
    [HttpPost("users/{id:guid}/ban")]
    public async Task<IActionResult> BanUser(Guid id, [FromBody] BanUserRequest request)
    {
        try
        {
            await _adminService.BanUserAsync(GetAdminId(), id, request.Reason);
            return Ok(new { message = "Tài khoản đã bị khóa." });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    /// <summary>POST /api/admin/users/{id}/unban</summary>
    [HttpPost("users/{id:guid}/unban")]
    public async Task<IActionResult> UnbanUser(Guid id)
    {
        try
        {
            await _adminService.UnbanUserAsync(GetAdminId(), id);
            return Ok(new { message = "Tài khoản đã được mở khóa." });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }
    }

    /// <summary>PUT /api/admin/users/{id}/role</summary>
    [HttpPut("users/{id:guid}/role")]
    public async Task<IActionResult> ChangeRole(Guid id, [FromBody] ChangeRoleRequest request)
    {
        try
        {
            await _adminService.ChangeRoleAsync(GetAdminId(), id, request.Role);
            return Ok(new { message = "Quyền hạn đã được cập nhật." });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>DELETE /api/admin/users/{id}</summary>
    [HttpDelete("users/{id:guid}")]
    public async Task<IActionResult> DeleteUser(Guid id)
    {
        try
        {
            await _adminService.DeleteUserAsync(GetAdminId(), id);
            return Ok(new { message = "Tài khoản đã bị xóa." });
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Không tìm thấy người dùng." });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    // ─── Analytics ────────────────────────────────────────────────────────────

    /// <summary>GET /api/admin/analytics/overview</summary>
    [HttpGet("analytics/overview")]
    public async Task<IActionResult> GetAnalyticsOverview()
    {
        var overview = await _adminService.GetAnalyticsOverviewAsync();
        return Ok(overview);
    }

    /// <summary>GET /api/admin/analytics/top-tracks?count=10</summary>
    [HttpGet("analytics/top-tracks")]
    public async Task<IActionResult> GetTopTracks([FromQuery] int count = 10)
    {
        var tracks = await _adminService.GetTopTracksAsync(count);
        return Ok(tracks);
    }

    /// <summary>GET /api/admin/analytics/daily-stats?from=2024-01-01&amp;to=2024-01-31</summary>
    [HttpGet("analytics/daily-stats")]
    public async Task<IActionResult> GetDailyStats(
        [FromQuery] DateOnly? from = null,
        [FromQuery] DateOnly? to = null)
    {
        var effectiveTo = to ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var effectiveFrom = from ?? effectiveTo.AddDays(-29);

        try
        {
            var stats = await _adminService.GetDailyStatsAsync(effectiveFrom, effectiveTo);
            return Ok(stats);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
