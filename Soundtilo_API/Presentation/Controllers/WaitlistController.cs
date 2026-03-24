using Application.DTOs.Playlists; // Tái sử dụng các DTO của Playlist như AddTrack, Reorder
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Presentation.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize] 
public class WaitlistController : ControllerBase
{
    private readonly WaitlistService _waitlistService; // Anh/chị cần tạo Service này tương tự PlaylistService

    public WaitlistController(WaitlistService waitlistService)
    {
        _waitlistService = waitlistService;
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException());

    // GET: api/waitlist
    // Nhớ thêm [FromServices] SoundtiloDbContext context vào tham số của hàm
    [HttpGet]
    public async Task<IActionResult> GetMyWaitlist([FromServices] Infrastructure.Data.SoundtiloDbContext context)
    {
        var userId = GetUserId();
        var waitlist = await _waitlistService.GetOrCreateUserWaitlistAsync(userId);

        // 1. Rút trích danh sách các ID bài hát đang có trong hàng đợi
        var trackIds = waitlist.Tracks.Select(t => t.TrackExternalId).ToList();

        // 2. Chạy vào bảng CachedTracks để lấy toàn bộ Tên bài, Ảnh bìa, Tên ca sĩ...
        var cachedTracks = await context.CachedTracks
                                .Where(c => trackIds.Contains(c.ExternalId))
                                .ToListAsync();

        // 3. Đóng gói lại thành JSON chuẩn để Flutter đọc được ngay
        var response = new
        {
            id = waitlist.Id,
            tracks = waitlist.Tracks.OrderBy(t => t.Position).Select(t =>
            {
                // Khớp ID hàng đợi với ID bài hát trong Cache
                var trackInfo = cachedTracks.FirstOrDefault(c => c.ExternalId == t.TrackExternalId);

                return new
                {
                    // Các trường này phải viết giống hệt các field trong TrackModel.fromJson của Flutter
                    id = trackInfo?.Id ?? Guid.Empty,
                    externalId = t.TrackExternalId,
                    title = trackInfo?.Title ?? "Unknown Track",
                    artistName = trackInfo?.ArtistName ?? "Unknown Artist",
                    artworkUrl = trackInfo?.ArtworkUrl,
                    streamUrl = trackInfo?.StreamUrl,
                    durationSeconds = trackInfo?.DurationSeconds ?? 0
                };
            }).ToList()
        };

        return Ok(response);
    }

    // POST: api/waitlist/tracks
    // Thêm bài hát vào hàng đợi
    [HttpPost("tracks")]
    public async Task<IActionResult> AddTrack([FromBody] AddTrackToPlaylistRequest request) // Tái sử dụng DTO
    {
        var userId = GetUserId();
        try
        {
            await _waitlistService.AddTrackAsync(userId, request);
            return Ok(new { message = "Đã thêm bài hát vào hàng đợi." });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
    }

    // DELETE: api/waitlist/tracks/{trackExternalId}
    // Xóa bài hát khỏi hàng đợi
    [HttpDelete("tracks/{trackExternalId}")]
    public async Task<IActionResult> RemoveTrack(string trackExternalId)
    {
        var userId = GetUserId();
        try
        {
            await _waitlistService.RemoveTrackAsync(userId, trackExternalId);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    // PUT: api/waitlist/tracks/reorder
    // Kéo thả, thay đổi thứ tự bài hát trong hàng đợi
    [HttpPut("tracks/reorder")]
    public async Task<IActionResult> ReorderTracks([FromBody] ReorderTracksRequest request) // Tái sử dụng DTO
    {
        var userId = GetUserId();
        try
        {
            await _waitlistService.ReorderTracksAsync(userId, request);
            return Ok(new { message = "Đã cập nhật thứ tự hàng đợi." });
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    // DELETE: api/waitlist
    // Xóa sạch hàng đợi
    [HttpDelete]
    public async Task<IActionResult> ClearWaitlist()
    {
        var userId = GetUserId();
        await _waitlistService.ClearWaitlistAsync(userId);
        return NoContent();
    }
}