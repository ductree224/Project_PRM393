using Domain.Enums;

namespace Domain.Entities;

public class Notification
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid? CreatedByAdminId { get; set; }
    public NotificationType Type { get; set; }
    public NotificationSource Source { get; set; }
    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
    public string? MetadataJson { get; set; }
    public bool IsRead { get; set; }
    public DateTime? ReadAt { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? ExpiresAt { get; set; }

    public User User { get; set; } = null!;
    public User? CreatedByAdmin { get; set; }
    public ICollection<NotificationDeliveryLog> DeliveryLogs { get; set; } = new List<NotificationDeliveryLog>();
}
