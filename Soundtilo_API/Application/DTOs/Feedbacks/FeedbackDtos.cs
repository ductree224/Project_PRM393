using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Application.DTOs.Feedbacks;

public class CreateFeedbackDto
{
    public string Category { get; set; } = "general";
    public string Priority { get; set; } = "medium";
    public string Title { get; set; } = "";
    public string Content { get; set; } = "";

    public string? DeviceInfo { get; set; }
    public string? AppVersion { get; set; }
    public string? Platform { get; set; }
    public string? AttachmentUrl { get; set; }
}

public class FeedbackDto
{
    public Guid Id { get; set; }
    public string Category { get; set; } = "";
    public string Priority { get; set; } = "";
    public string Title { get; set; } = "";
    public string Content { get; set; } = "";
    public string Status { get; set; } = "";
    public string? AdminReply { get; set; }
    public DateTime CreatedAt { get; set; }
}
