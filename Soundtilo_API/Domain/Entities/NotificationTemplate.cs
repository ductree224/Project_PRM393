using Domain.Enums;

namespace Domain.Entities;

public class NotificationTemplate
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public NotificationType Type { get; set; }
    public string TitleTemplate { get; set; } = string.Empty;
    public string MessageTemplate { get; set; } = string.Empty;
    public string? MetadataTemplateJson { get; set; }
    public bool IsActive { get; set; } = true;
    public Guid? CreatedByAdminId { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public User? CreatedByAdmin { get; set; }
    public ICollection<NotificationSchedule> Schedules { get; set; } = new List<NotificationSchedule>();
}
