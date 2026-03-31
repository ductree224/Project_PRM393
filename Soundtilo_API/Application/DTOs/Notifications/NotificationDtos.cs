using Domain.Enums;

namespace Application.DTOs.Notifications;

public record NotificationDto(
    Guid Id,
    NotificationType Type,
    NotificationSource Source,
    string Title,
    string Message,
    string? MetadataJson,
    bool IsRead,
    DateTime CreatedAt,
    DateTime? ReadAt,
    DateTime? ExpiresAt
);

public record NotificationListResponse(
    IEnumerable<NotificationDto> Notifications,
    int Total,
    int Page,
    int PageSize,
    int TotalPages
);

public record SendNotificationRequest(
    NotificationType Type,
    string Title,
    string Message,
    string? MetadataJson,
    DateTime? ExpiresAt
);

public record CreateNotificationTemplateRequest(
    string Name,
    NotificationType Type,
    string TitleTemplate,
    string MessageTemplate,
    string? MetadataTemplateJson,
    bool IsActive
);

public record UpdateNotificationTemplateRequest(
    string Name,
    NotificationType Type,
    string TitleTemplate,
    string MessageTemplate,
    string? MetadataTemplateJson,
    bool IsActive
);

public record NotificationTemplateDto(
    Guid Id,
    string Name,
    NotificationType Type,
    string TitleTemplate,
    string MessageTemplate,
    string? MetadataTemplateJson,
    bool IsActive,
    Guid? CreatedByAdminId,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public record NotificationTemplateListResponse(
    IEnumerable<NotificationTemplateDto> Templates,
    int Total,
    int Page,
    int PageSize,
    int TotalPages
);

public record CreateNotificationScheduleRequest(
    Guid? TemplateId,
    Guid? TargetUserId,
    NotificationType Type,
    NotificationTargetScope TargetScope,
    NotificationRecurrence Recurrence,
    string Title,
    string Message,
    string? MetadataJson,
    DateTime ScheduledFor
);

public record UpdateNotificationScheduleRequest(
    Guid? TemplateId,
    Guid? TargetUserId,
    NotificationType Type,
    NotificationTargetScope TargetScope,
    NotificationRecurrence Recurrence,
    string Title,
    string Message,
    string? MetadataJson,
    DateTime ScheduledFor
);

public record NotificationScheduleDto(
    Guid Id,
    Guid? TemplateId,
    Guid? TargetUserId,
    Guid CreatedByAdminId,
    NotificationType Type,
    NotificationSource Source,
    NotificationTargetScope TargetScope,
    NotificationRecurrence Recurrence,
    NotificationScheduleStatus Status,
    string Title,
    string Message,
    string? MetadataJson,
    DateTime ScheduledFor,
    DateTime? ProcessedAt,
    int Attempts,
    string? LastError,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public record NotificationScheduleListResponse(
    IEnumerable<NotificationScheduleDto> Schedules,
    int Total,
    int Page,
    int PageSize,
    int TotalPages
);

public record NotificationDeliveryLogDto(
    Guid Id,
    Guid? NotificationId,
    Guid? ScheduleId,
    Guid UserId,
    string Channel,
    string Status,
    string? ErrorMessage,
    DateTime DeliveredAt
);

public record NotificationDeliveryLogListResponse(
    IEnumerable<NotificationDeliveryLogDto> Logs,
    int Total,
    int Page,
    int PageSize,
    int TotalPages
);
