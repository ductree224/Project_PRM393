using Domain.Entities;

public class Feedback
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }

    // classification
    public string Category { get; set; } = "general";
    // bug | ux | performance | payment | other

    public string Priority { get; set; } = "medium";
    // low | medium | high | critical

    // content
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;

    // metadata
    public string? DeviceInfo { get; set; }
    public string? AppVersion { get; set; }
    public string? Platform { get; set; }

    // attachment   -> image chẳng hạn :V
    public string? AttachmentUrl { get; set; }

    // workflow
    public string Status { get; set; } = "pending";
    // pending | reviewing | in_progress | resolved | rejected

    // admin handling
    public string? AdminReply { get; set; }
    public Guid? HandledByAdminId { get; set; }

    public DateTime CreatedAt { get; set; }
    public DateTime? HandledAt { get; set; }

    public User User { get; set; } = null!;
}