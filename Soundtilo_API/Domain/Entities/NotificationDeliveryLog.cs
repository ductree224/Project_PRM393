namespace Domain.Entities;

public class NotificationDeliveryLog
{
    public Guid Id { get; set; }
    public Guid? NotificationId { get; set; }
    public Guid? ScheduleId { get; set; }
    public Guid UserId { get; set; }
    public string Channel { get; set; } = "in_app";
    public string Status { get; set; } = "sent";
    public string? ErrorMessage { get; set; }
    public DateTime DeliveredAt { get; set; }

    public Notification? Notification { get; set; }
    public NotificationSchedule? Schedule { get; set; }
    public User User { get; set; } = null!;
}
