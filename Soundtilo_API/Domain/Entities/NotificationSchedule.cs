using Domain.Enums;

namespace Domain.Entities;

public class NotificationSchedule
{
    public Guid Id { get; set; }
    public Guid? TemplateId { get; set; }
    public Guid? TargetUserId { get; set; }
    public Guid CreatedByAdminId { get; set; }
    public NotificationType Type { get; set; }
    public NotificationSource Source { get; set; }
    public NotificationTargetScope TargetScope { get; set; }
    public NotificationRecurrence Recurrence { get; set; } = NotificationRecurrence.OneTime;
    public NotificationScheduleStatus Status { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string? MetadataJson { get; set; }
    public DateTime ScheduledFor { get; set; }
    public DateTime? ProcessedAt { get; set; }
    public int Attempts { get; set; }
    public string? LastError { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }

    public NotificationTemplate? Template { get; set; }
    public User? TargetUser { get; set; }
    public User CreatedByAdmin { get; set; } = null!;
    public ICollection<NotificationDeliveryLog> DeliveryLogs { get; set; } = new List<NotificationDeliveryLog>();
}
