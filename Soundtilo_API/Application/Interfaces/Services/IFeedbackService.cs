using Application.Common.Models;
using Application.DTOs.Feedbacks;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.Interfaces.Services;

public interface IFeedbackService
{
    Task CreateAsync(Guid userId , CreateFeedbackDto dto);

    Task<PagedResponse<FeedbackDto>> GetMyFeedbacks(
        Guid userId ,
        string? status ,
        int page ,
        int pageSize);

    Task<PagedResponse<FeedbackDto>> AdminGetAsync(
        string? status ,
        string? category ,
        int page ,
        int pageSize);

    Task HandleAsync(Guid id , string reply , string status , Guid adminId);
}
