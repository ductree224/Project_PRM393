using Domain.Entities;

namespace Domain.Interfaces;

public interface ICommentRepository
{
    Task<IEnumerable<Comment>> GetByTrackAsync(string trackExternalId, int page = 1, int pageSize = 20);
    Task<Comment> AddAsync(Comment comment);
    Task<Comment?> GetByIdAsync(Guid commentId);
    Task DeleteAsync(Guid commentId);
    Task<int> GetCountByTrackAsync(string trackExternalId);
}
