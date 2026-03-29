using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Application.DTOs.Users;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using System.IO;
using System.Linq;

namespace Presentation.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class UsersController : ControllerBase
{
    private readonly UserService _userService;

    public UsersController(UserService userService)
    {
        _userService = userService;
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException());

    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        var userId = GetUserId();
        var profile = await _userService.GetProfileAsync(userId);
        if (profile == null)
            return NotFound(new { message = "Không tìm thấy người dùng." });

        return Ok(profile);
    }

    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
    {
        var userId = GetUserId();
        try
        {
            var profile = await _userService.UpdateProfileAsync(userId, request);
            if (profile == null)
                return NotFound(new { message = "Không tìm thấy người dùng." });

            return Ok(profile);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpGet("profile/blocked-users")]
    public async Task<IActionResult> GetBlockedUsers()
    {
        var userId = GetUserId();
        var blockedUsers = await _userService.GetBlockedUsersAsync(userId);
        return Ok(blockedUsers);
    }

    [HttpPost("profile/blocked-users")]
    public async Task<IActionResult> BlockUser([FromBody] BlockUserRequest request)
    {
        var userId = GetUserId();
        try
        {
            var result = await _userService.BlockUserAsync(userId, request);
            if (!result)
            {
                return NotFound(new { message = "Không tìm thấy người dùng cần chặn." });
            }

            return NoContent();
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("profile/blocked-users/{blockedUserId:guid}")]
    public async Task<IActionResult> UnblockUser(Guid blockedUserId)
    {
        var userId = GetUserId();
        var result = await _userService.UnblockUserAsync(userId, blockedUserId);
        if (!result)
        {
            return NotFound(new { message = "Không tìm thấy người dùng trong danh sách chặn." });
        }

        return NoContent();
    }

    [HttpGet("profile/badges")]
    public async Task<IActionResult> GetMyBadges()
    {
        var userId = GetUserId();
        var badges = await _userService.GetUserBadgesAsync(userId);
        return Ok(badges);
    }

    [HttpGet("badges/catalog")]
    public async Task<IActionResult> GetBadgeCatalog([FromQuery] bool activeOnly = false)
    {
        var badges = await _userService.GetBadgeCatalogAsync(activeOnly);
        return Ok(badges);
    }

    [HttpPost("badges/catalog")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> CreateBadge([FromBody] CreateProfileBadgeRequest request)
    {
        try
        {
            var badge = await _userService.CreateBadgeAsync(request);
            return Ok(badge);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpPost("{targetUserId:guid}/badges")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> AssignBadge(Guid targetUserId, [FromBody] AssignBadgeRequest request)
    {
        var adminId = GetUserId();
        try
        {
            var result = await _userService.AssignBadgeAsync(adminId, targetUserId, request);
            if (!result)
            {
                return NotFound(new { message = "Không tìm thấy người dùng." });
            }

            return NoContent();
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{targetUserId:guid}/badges/{badgeId:guid}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> RemoveBadge(Guid targetUserId, Guid badgeId)
    {
        var result = await _userService.RemoveBadgeAsync(targetUserId, badgeId);
        if (!result)
        {
            return NotFound(new { message = "Không tìm thấy badge đã gán cho user." });
        }

        return NoContent();
    }

    [HttpPost("profile/avatar")]
    public async Task<IActionResult> UploadAvatar([FromForm] IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest(new { message = "No file uploaded." });

        var ext = Path.GetExtension(file.FileName) ?? string.Empty;
        var allowed = new[] { ".png", ".jpg", ".jpeg", ".gif", ".webp" };
        if (!allowed.Contains(ext.ToLowerInvariant()))
            return BadRequest(new { message = "Unsupported file type." });

        var uploadsRoot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "avatars");
        Directory.CreateDirectory(uploadsRoot);

        var fileName = $"{Guid.NewGuid()}{ext}";
        var path = Path.Combine(uploadsRoot, fileName);
        await using (var stream = System.IO.File.Create(path))
        {
            await file.CopyToAsync(stream);
        }

        var url = $"{Request.Scheme}://{Request.Host}/avatars/{fileName}";

        // Update user's profile to use new avatar URL
        var userId = GetUserId();
        var profile = await _userService.UpdateProfileAsync(userId, new Application.DTOs.Users.UpdateProfileRequest(AvatarUrl: url));

        return Ok(new { url, profile });
    }
}
