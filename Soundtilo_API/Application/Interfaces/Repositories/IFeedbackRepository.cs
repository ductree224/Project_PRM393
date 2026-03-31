using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces.Repositories;

public interface IFeedbackRepository
{
    Task AddAsync(Feedback feedback);
    Task<Feedback?> GetByIdAsync(Guid id);

    Task<List<Feedback>> GetByUserAsync(Guid userId);

    Task<List<Feedback>> FilterAsync(
        string? status ,
        string? category ,
        int page ,
        int pageSize);

    Task SaveChangesAsync();
    IQueryable<Feedback> Query();
}
