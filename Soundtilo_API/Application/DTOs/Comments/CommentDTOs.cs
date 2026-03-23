namespace Application.DTOs.Comments;

public record CommentDto(
    Guid Id,
    string Username,
    string? AvatarUrl,
    string Content,
    DateTime CreatedAt
);

public record CommentListResponse(
    IEnumerable<CommentDto> Comments,
    int TotalCount
);

public record CreateCommentRequest(
    string Content
);
