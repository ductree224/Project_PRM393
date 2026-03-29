using Application.DTOs.Comments;
using Domain.Entities;
using Domain.Interfaces;

namespace Application.Services;

public class CommentService
{
    private readonly ICommentRepository _commentRepository;
    private readonly IUserRepository _userRepository;

    public CommentService(ICommentRepository commentRepository, IUserRepository userRepository)
    {
        _commentRepository = commentRepository;
        _userRepository = userRepository;
    }

    public async Task<CommentListResponse> GetCommentsAsync(string trackExternalId, int page = 1, int pageSize = 20)
    {
        var comments = await _commentRepository.GetByTrackAsync(trackExternalId, page, pageSize);
        var totalCount = await _commentRepository.GetCountByTrackAsync(trackExternalId);

        return new CommentListResponse(
            Comments: comments.Select(c => new CommentDto(
                Id: c.Id,
                Username: c.User.DisplayName ?? c.User.Username,
                AvatarUrl: c.User.AvatarUrl,
                Content: c.Content,
                CreatedAt: c.CreatedAt
            )),
            TotalCount: totalCount
        );
    }

    public async Task<CommentDto> AddCommentAsync(Guid userId, string trackExternalId, CreateCommentRequest request)
    {
        var user = await _userRepository.GetByIdAsync(userId);
        if (user == null)
            throw new KeyNotFoundException("Người dùng không tồn tại.");

        if (!user.AllowComments)
            throw new InvalidOperationException("Tính năng bình luận đang bị tắt trong cài đặt hồ sơ của bạn.");

        var comment = new Comment
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TrackExternalId = trackExternalId,
            Content = request.Content.Trim(),
            CreatedAt = DateTime.UtcNow
        };

        var created = await _commentRepository.AddAsync(comment);

        return new CommentDto(
            Id: created.Id,
            Username: created.User.DisplayName ?? created.User.Username,
            AvatarUrl: created.User.AvatarUrl,
            Content: created.Content,
            CreatedAt: created.CreatedAt
        );
    }

    public async Task DeleteCommentAsync(Guid commentId, Guid userId)
    {
        var comment = await _commentRepository.GetByIdAsync(commentId);
        if (comment == null)
            throw new KeyNotFoundException("Bình luận không tồn tại.");
        if (comment.UserId != userId)
            throw new UnauthorizedAccessException("Bạn không có quyền xoá bình luận này.");

        await _commentRepository.DeleteAsync(commentId);
    }
}
