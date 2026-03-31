using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Application.DTOs.Notifications;
using Application.Services;
using Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize]
public class NotificationsController : ControllerBase
{
    private readonly NotificationService _notificationService;

    public NotificationsController(NotificationService notificationService)
    {
        _notificationService = notificationService;
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException());

    [HttpGet("inbox")]
    public async Task<IActionResult> GetInbox([FromQuery] int page = 1, [FromQuery] int pageSize = 20, [FromQuery] bool? isRead = null)
    {
        var result = await _notificationService.GetInboxAsync(GetUserId(), page, pageSize, isRead);
        return Ok(result);
    }

    [HttpGet("unread-count")]
    public async Task<IActionResult> GetUnreadCount()
    {
        var count = await _notificationService.GetUnreadCountAsync(GetUserId());
        return Ok(new { unreadCount = count });
    }

    [HttpPost("{notificationId:guid}/read")]
    public async Task<IActionResult> MarkAsRead(Guid notificationId)
    {
        try
        {
            await _notificationService.MarkAsReadAsync(GetUserId(), notificationId);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Không tìm thấy thông báo." });
        }
    }

    [HttpPost("read-all")]
    public async Task<IActionResult> MarkAllAsRead()
    {
        await _notificationService.MarkAllAsReadAsync(GetUserId());
        return NoContent();
    }

    [HttpPost("admin/send/user/{userId:guid}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> SendToUser(Guid userId, [FromBody] SendNotificationRequest request)
    {
        var adminId = GetUserId();
        var notification = await _notificationService.SendToUserAsync(
            adminId,
            userId,
            request.Type,
            NotificationSource.Manual,
            request.Title,
            request.Message,
            request.MetadataJson,
            request.ExpiresAt);

        return Ok(notification);
    }

    [HttpPost("admin/send/broadcast")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> SendBroadcast([FromBody] SendNotificationRequest request)
    {
        var adminId = GetUserId();
        var sent = await _notificationService.SendBroadcastAsync(
            adminId,
            request.Type,
            NotificationSource.Manual,
            request.Title,
            request.Message,
            request.MetadataJson,
            request.ExpiresAt);

        return Ok(new { sent });
    }

    [HttpGet("admin/templates")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> GetTemplates([FromQuery] int page = 1, [FromQuery] int pageSize = 20, [FromQuery] bool? isActive = null)
    {
        var result = await _notificationService.GetTemplatesAsync(page, pageSize, isActive);
        return Ok(result);
    }

    [HttpPost("admin/templates")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> CreateTemplate([FromBody] CreateNotificationTemplateRequest request)
    {
        var template = await _notificationService.CreateTemplateAsync(GetUserId(), request);
        return Ok(template);
    }

    [HttpPut("admin/templates/{templateId:guid}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> UpdateTemplate(Guid templateId, [FromBody] UpdateNotificationTemplateRequest request)
    {
        try
        {
            var template = await _notificationService.UpdateTemplateAsync(GetUserId(), templateId, request);
            return Ok(template);
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Template không tồn tại." });
        }
    }

    [HttpDelete("admin/templates/{templateId:guid}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> DeleteTemplate(Guid templateId)
    {
        try
        {
            await _notificationService.DeleteTemplateAsync(GetUserId(), templateId);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Template không tồn tại." });
        }
    }

    [HttpGet("admin/schedules")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> GetSchedules([FromQuery] int page = 1, [FromQuery] int pageSize = 20, [FromQuery] NotificationScheduleStatus? status = null)
    {
        var result = await _notificationService.GetSchedulesAsync(page, pageSize, status);
        return Ok(result);
    }

    [HttpPost("admin/schedules")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> CreateSchedule([FromBody] CreateNotificationScheduleRequest request)
    {
        try
        {
            var schedule = await _notificationService.CreateScheduleAsync(GetUserId(), request);
            return Ok(schedule);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpPut("admin/schedules/{scheduleId:guid}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> UpdateSchedule(Guid scheduleId, [FromBody] UpdateNotificationScheduleRequest request)
    {
        try
        {
            var schedule = await _notificationService.UpdateScheduleAsync(GetUserId(), scheduleId, request);
            return Ok(schedule);
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Schedule không tồn tại." });
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

    [HttpDelete("admin/schedules/{scheduleId:guid}")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> CancelSchedule(Guid scheduleId)
    {
        try
        {
            await _notificationService.CancelScheduleAsync(GetUserId(), scheduleId);
            return NoContent();
        }
        catch (KeyNotFoundException)
        {
            return NotFound(new { message = "Schedule không tồn tại." });
        }
        catch (InvalidOperationException ex)
        {
            return Conflict(new { message = ex.Message });
        }
    }

    [HttpGet("admin/delivery-logs")]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> GetDeliveryLogs([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var result = await _notificationService.GetDeliveryLogsAsync(page, pageSize);
        return Ok(result);
    }
}
