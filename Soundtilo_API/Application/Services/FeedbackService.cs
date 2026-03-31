using Application.Common.Models;
using Application.DTOs.Feedbacks;
using Application.Interfaces.Repositories;
using Application.Interfaces.Services;
using Microsoft.EntityFrameworkCore;
using Domain.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Services;

public class FeedbackService : IFeedbackService
{
    private readonly IFeedbackRepository _repo;

    private readonly INotificationService _notificationService;

    public FeedbackService(
        IFeedbackRepository repo ,
        INotificationService notificationService)
    {
        _repo = repo;
        _notificationService = notificationService;
    }

    public async Task CreateAsync(Guid userId , CreateFeedbackDto dto)
    {
        var feedback = new Feedback
        {
            Id = Guid.NewGuid() ,
            UserId = userId ,
            Category = dto.Category ,
            Priority = dto.Priority ,
            Title = dto.Title ,
            Content = dto.Content ,
            DeviceInfo = dto.DeviceInfo ,
            AppVersion = dto.AppVersion ,
            Platform = dto.Platform ,
            AttachmentUrl = dto.AttachmentUrl ,
            Status = "pending" ,
            CreatedAt = DateTime.UtcNow
        };

        await _repo.AddAsync(feedback);
        await _repo.SaveChangesAsync();

        await _notificationService.NotifyAdminNewFeedbackAsync(feedback);
    }

    public async Task<PagedResponse<FeedbackDto>> GetMyFeedbacks(
        Guid userId ,
        string? status ,
        int page ,
        int pageSize)
    {
        var query = _repo.Query()
            .Where(x => x.UserId == userId);

        if ( !string.IsNullOrEmpty(status) )
            query = query.Where(x => x.Status == status);

        var total = await query.CountAsync();

        var items = await query
            .OrderByDescending(x => x.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return new PagedResponse<FeedbackDto>
        {
            Items = items.Select(Map).ToList() ,
            Total = total ,
            Page = page ,
            PageSize = pageSize ,
            TotalPages = (int) Math.Ceiling(total / (double) pageSize)
        };
    }

    public async Task<PagedResponse<FeedbackDto>> AdminGetAsync(
    string? status ,
    string? category ,
    int page ,
    int pageSize)
    {
        var query = _repo.Query();

        if ( !string.IsNullOrEmpty(status) )
            query = query.Where(x => x.Status == status);

        if ( !string.IsNullOrEmpty(category) )
            query = query.Where(x => x.Category == category);

        var total = await query.CountAsync();

        var items = await query
            .OrderByDescending(x => x.CreatedAt)
            .Skip((page - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();

        return new PagedResponse<FeedbackDto>
        {
            Items = items.Select(Map).ToList() ,
            Total = total ,
            Page = page ,
            PageSize = pageSize ,
            TotalPages = (int) Math.Ceiling(total / (double) pageSize)
        };
    }

    public async Task HandleAsync(Guid id , string reply , string status , Guid adminId)
    {
        var feedback = await _repo.GetByIdAsync(id);
        if ( feedback == null ) throw new Exception("Not found");

        feedback.AdminReply = reply;
        feedback.Status = status;
        feedback.HandledByAdminId = adminId;
        feedback.HandledAt = DateTime.UtcNow;

        await _repo.SaveChangesAsync();

        await _notificationService.NotifyUserFeedbackHandledAsync(feedback);
    }

    private static FeedbackDto Map(Feedback x) => new()
    {
        Id = x.Id ,
        Category = x.Category ,
        Priority = x.Priority ,
        Title = x.Title ,
        Content = x.Content ,
        Status = x.Status ,
        AdminReply = x.AdminReply ,
        CreatedAt = x.CreatedAt
    };
}
