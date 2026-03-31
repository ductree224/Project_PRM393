using Application.Interfaces.Repositories;
using Domain.Entities;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Repositories;

public class FeedbackRepository : IFeedbackRepository
{
    private readonly SoundtiloDbContext _context;

    public FeedbackRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task AddAsync(Feedback feedback)
    {
        await _context.Feedbacks.AddAsync(feedback);
    }

    public async Task<List<Feedback>> GetAllAsync()
    {
        return await _context.Feedbacks
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync();
    }

    public async Task<Feedback?> GetByIdAsync(Guid id)
    {
        return await _context.Feedbacks.FindAsync(id);
    }

    public async Task SaveChangesAsync()
    {
        await _context.SaveChangesAsync();
    }
    public async Task<List<Feedback>> FilterAsync(
                                        string? status ,
                                        string? category ,
                                        int page ,
                                        int pageSize)
    {
        var query = _context.Feedbacks.AsQueryable();

        if ( !string.IsNullOrEmpty(status) )
            query = query.Where(x => x.Status == status);

        if ( !string.IsNullOrEmpty(category) )
            query = query.Where(x => x.Category == category);

        return await query
            .OrderByDescending(x => x.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task<List<Feedback>> GetByUserAsync(Guid userId)
    {
        return await _context.Feedbacks.Where(f => f.UserId == userId).ToListAsync();
    }
    public IQueryable<Feedback> Query()
    {
        return _context.Feedbacks.AsQueryable();
    }
}
