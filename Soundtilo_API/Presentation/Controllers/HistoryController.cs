using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Application.DTOs.History;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class HistoryController : ControllerBase
{
    private readonly HistoryService _historyService;

    public HistoryController(HistoryService historyService)
    {
        _historyService = historyService;
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException());

    [HttpGet]
    public async Task<IActionResult> GetHistory([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var userId = GetUserId();
        var result = await _historyService.GetHistoryAsync(userId, page, pageSize);
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> RecordListen([FromBody] RecordListenRequest request)
    {
        var userId = GetUserId();
        await _historyService.RecordListenAsync(userId, request);
        return Ok(new { message = "Đã ghi nhận lịch sử nghe." });
    }

    [HttpDelete]
    public async Task<IActionResult> DeleteHistory([FromBody] DeleteHistoryRequest request)
    {
        var userId = GetUserId();
        var deletedCount = await _historyService.DeleteHistoryAsync(userId, request.HistoryIds);
        return Ok(new DeleteHistoryResponse(deletedCount));
    }
}
