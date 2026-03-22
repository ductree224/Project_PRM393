namespace Domain.Entities;

public class AdminAuditLog
{
    public Guid Id { get; set; }
    public Guid AdminId { get; set; }
    public string Action { get; set; } = string.Empty;
    public string? TargetType { get; set; }
    public string? TargetId { get; set; }
    public string? Details { get; set; } // JSON string
    public DateTime CreatedAt { get; set; }

    // Navigation properties
    public User Admin { get; set; } = null!;
}
