using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Application.DTOs.Users;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

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
        var profile = await _userService.UpdateProfileAsync(userId, request);
        if (profile == null)
            return NotFound(new { message = "Không tìm thấy người dùng." });

        return Ok(profile);
    }
    //[HttpPost("change-password")]
    //public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    //{
    //    try
    //    {
    //        var userId = GetUserId();
    //        var result = await _userService.ChangePasswordAsync(userId, request);
            
    //        if (result)
    //            return Ok(new { message = "Đổi mật khẩu thành công." });
                
    //        return BadRequest(new { message = "Đổi mật khẩu thất bại." });
    //    }
    //    catch (UnauthorizedAccessException ex) // Thường dùng khi Mật khẩu cũ không đúng
    //    {
    //        return Unauthorized(new { message = ex.Message });
    //    }
    //    catch (Exception ex)
    //    {
    //        return BadRequest(new { message = ex.Message });
    //    }
    //}
    [HttpPost("change-password")]
    public async Task<IActionResult> ChangePasswordAsync([FromBody] ChangePasswordRequest request)
    {
        try
        {
            // Lấy ID của user đang đăng nhập từ Token
            var userId = GetUserId();

            // Gọi hàm xử lý logic từ UserService mà chúng ta vừa viết
            var result = await _userService.ChangePasswordAsync(userId, request);

            if (result)
            {
                return Ok(new { message = "Đổi mật khẩu thành công." });
            }

            return BadRequest(new { message = "Đổi mật khẩu thất bại. Vui lòng thử lại sau." });
        }
        catch (UnauthorizedAccessException ex)
        {
            // Bắt lỗi khi nhập sai mật khẩu cũ
            return Unauthorized(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            // Bắt các lỗi hệ thống khác
            return BadRequest(new { message = ex.Message });
        }
    }
}
