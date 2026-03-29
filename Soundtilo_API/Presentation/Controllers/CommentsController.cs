using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Application.DTOs.Comments;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CommentsController : ControllerBase
{
    private readonly CommentService _commentService;

    public CommentsController(CommentService commentService)
    {
        _commentService = commentService;
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException());

    [HttpGet("{trackExternalId}")]
    public async Task<IActionResult> GetComments(string trackExternalId, [FromQuery] int page = 1, [FromQuery] int pageSize = 20)
    {
        var result = await _commentService.GetCommentsAsync(trackExternalId, page, pageSize);
        return Ok(result);
    }

    [HttpPost("{trackExternalId}")]
    public async Task<IActionResult> AddComment(string trackExternalId, [FromBody] CreateCommentRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Content))
            return BadRequest(new { message = "Nội dung bình luận không được để trống." });

        if (request.Content.Length > 500)
            return BadRequest(new { message = "Bình luận không được vượt quá 500 ký tự." });

        var userId = GetUserId();
        try
        {
            var comment = await _commentService.AddCommentAsync(userId, trackExternalId, request);
            return CreatedAtAction(nameof(GetComments), new { trackExternalId }, comment);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [HttpDelete("{commentId:guid}")]
    public async Task<IActionResult> DeleteComment(Guid commentId)
    {
        var userId = GetUserId();
        try
        {
            await _commentService.DeleteCommentAsync(commentId, userId);
            return NoContent();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
    }
}
