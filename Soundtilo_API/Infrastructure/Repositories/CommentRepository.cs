using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class CommentRepository : ICommentRepository
{
    private readonly SoundtiloDbContext _context;

    public CommentRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<Comment>> GetByTrackAsync(string trackExternalId, int page = 1, int pageSize = 20)
    {
        return await _context.Comments
            .Include(c => c.User)
            .Where(c => c.TrackExternalId == trackExternalId)
            .OrderByDescending(c => c.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task<Comment> AddAsync(Comment comment)
    {
        _context.Comments.Add(comment);
        await _context.SaveChangesAsync();

        // Reload with User navigation for DTO mapping
        await _context.Entry(comment).Reference(c => c.User).LoadAsync();
        return comment;
    }

    public async Task<Comment?> GetByIdAsync(Guid commentId)
    {
        return await _context.Comments.FindAsync(commentId);
    }

    public async Task DeleteAsync(Guid commentId)
    {
        var comment = await _context.Comments.FindAsync(commentId);
        if (comment != null)
        {
            _context.Comments.Remove(comment);
            await _context.SaveChangesAsync();
        }
    }

    public async Task<int> GetCountByTrackAsync(string trackExternalId)
    {
        return await _context.Comments.CountAsync(c => c.TrackExternalId == trackExternalId);
    }
}
