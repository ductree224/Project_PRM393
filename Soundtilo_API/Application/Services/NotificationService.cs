using Application.DTOs.Notifications;
using Application.Interfaces;
using Domain.Entities;
using Domain.Enums;
using Domain.Interfaces;

namespace Application.Services;

public class NotificationService
{
    private readonly INotificationRepository _notificationRepository;
    private readonly INotificationTemplateRepository _templateRepository;
    private readonly INotificationScheduleRepository _scheduleRepository;
    private readonly INotificationDeliveryLogRepository _deliveryLogRepository;
    private readonly INotificationRealtimePublisher _realtimePublisher;
    private readonly IAdminAuditLogRepository _adminAuditLogRepository;

    public NotificationService(
        INotificationRepository notificationRepository,
        INotificationTemplateRepository templateRepository,
        INotificationScheduleRepository scheduleRepository,
        INotificationDeliveryLogRepository deliveryLogRepository,
        INotificationRealtimePublisher realtimePublisher,
        IAdminAuditLogRepository adminAuditLogRepository)
    {
        _notificationRepository = notificationRepository;
        _templateRepository = templateRepository;
        _scheduleRepository = scheduleRepository;
        _deliveryLogRepository = deliveryLogRepository;
        _realtimePublisher = realtimePublisher;
        _adminAuditLogRepository = adminAuditLogRepository;
    }

    public async Task<NotificationDto> SendToUserAsync(
        Guid actorAdminId,
        Guid userId,
        NotificationType type,
        NotificationSource source,
        string title,
        string message,
        string? metadataJson,
        DateTime? expiresAt,
        Guid? scheduleId = null,
        CancellationToken cancellationToken = default)
    {
        var notification = new Notification
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CreatedByAdminId = actorAdminId,
            Type = type,
            Source = source,
            Title = title,
            Message = message,
            MetadataJson = metadataJson,
            IsRead = false,
            CreatedAt = DateTime.UtcNow,
            ExpiresAt = expiresAt
        };

        await _notificationRepository.AddAsync(notification);

        await _deliveryLogRepository.AddRangeAsync([
            new NotificationDeliveryLog
            {
                Id = Guid.NewGuid(),
                NotificationId = notification.Id,
                ScheduleId = scheduleId,
                UserId = userId,
                Channel = "in_app_signalr",
                Status = "sent",
                DeliveredAt = DateTime.UtcNow
            }
        ]);

        var dto = MapNotificationDto(notification);
        await _realtimePublisher.PublishToUserAsync(userId, dto, cancellationToken);

        await LogAdminActionAsync(actorAdminId, "SEND_NOTIFICATION_TO_USER", "Notification", notification.Id.ToString(),
            $"{{\"userId\":\"{userId}\",\"type\":\"{type}\"}}");

        return dto;
    }

    public async Task<int> SendBroadcastAsync(
        Guid actorAdminId,
        NotificationType type,
        NotificationSource source,
        string title,
        string message,
        string? metadataJson,
        DateTime? expiresAt,
        Guid? scheduleId = null,
        CancellationToken cancellationToken = default)
    {
        var userIds = await _notificationRepository.GetAllUserIdsAsync();
        if (userIds.Count == 0)
        {
            return 0;
        }

        var now = DateTime.UtcNow;
        var notifications = userIds.Select(userId => new Notification
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            CreatedByAdminId = actorAdminId,
            Type = type,
            Source = source,
            Title = title,
            Message = message,
            MetadataJson = metadataJson,
            IsRead = false,
            CreatedAt = now,
            ExpiresAt = expiresAt
        }).ToList();

        await _notificationRepository.AddRangeAsync(notifications);

        var logs = notifications.Select(x => new NotificationDeliveryLog
        {
            Id = Guid.NewGuid(),
            NotificationId = x.Id,
            ScheduleId = scheduleId,
            UserId = x.UserId,
            Channel = "in_app_signalr",
            Status = "sent",
            DeliveredAt = now
        });
        await _deliveryLogRepository.AddRangeAsync(logs);

        foreach (var notification in notifications)
        {
            await _realtimePublisher.PublishToUserAsync(notification.UserId, MapNotificationDto(notification), cancellationToken);
        }

        await LogAdminActionAsync(actorAdminId, "SEND_BROADCAST_NOTIFICATION", "Notification", null,
            $"{{\"type\":\"{type}\",\"totalRecipients\":{notifications.Count}}}");

        return notifications.Count;
    }

    public async Task<NotificationListResponse> GetInboxAsync(Guid userId, int page = 1, int pageSize = 20, bool? isRead = null)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var (items, total) = await _notificationRepository.GetByUserIdAsync(userId, safePage, safePageSize, isRead);
        var totalPages = (int)Math.Ceiling(total / (double)safePageSize);

        return new NotificationListResponse(items.Select(MapNotificationDto), total, safePage, safePageSize, totalPages);
    }

    public Task<int> GetUnreadCountAsync(Guid userId)
    {
        return _notificationRepository.GetUnreadCountAsync(userId);
    }

    public async Task MarkAsReadAsync(Guid userId, Guid notificationId)
    {
        var affected = await _notificationRepository.MarkAsReadAsync(userId, notificationId);
        if (affected == 0)
        {
            throw new KeyNotFoundException("Notification not found.");
        }
    }

    public Task MarkAllAsReadAsync(Guid userId)
    {
        return _notificationRepository.MarkAllAsReadAsync(userId);
    }

    public async Task<NotificationTemplateDto> CreateTemplateAsync(Guid adminId, CreateNotificationTemplateRequest request)
    {
        var now = DateTime.UtcNow;
        var template = new NotificationTemplate
        {
            Id = Guid.NewGuid(),
            Name = request.Name.Trim(),
            Type = request.Type,
            TitleTemplate = request.TitleTemplate.Trim(),
            MessageTemplate = request.MessageTemplate.Trim(),
            MetadataTemplateJson = request.MetadataTemplateJson,
            IsActive = request.IsActive,
            CreatedByAdminId = adminId,
            CreatedAt = now,
            UpdatedAt = now
        };

        await _templateRepository.AddAsync(template);

        await LogAdminActionAsync(adminId, "CREATE_NOTIFICATION_TEMPLATE", "NotificationTemplate", template.Id.ToString(), null);

        return MapTemplateDto(template);
    }

    public async Task<NotificationTemplateDto> UpdateTemplateAsync(Guid adminId, Guid templateId, UpdateNotificationTemplateRequest request)
    {
        var template = await _templateRepository.GetByIdAsync(templateId)
            ?? throw new KeyNotFoundException("Template not found.");

        template.Name = request.Name.Trim();
        template.Type = request.Type;
        template.TitleTemplate = request.TitleTemplate.Trim();
        template.MessageTemplate = request.MessageTemplate.Trim();
        template.MetadataTemplateJson = request.MetadataTemplateJson;
        template.IsActive = request.IsActive;
        template.UpdatedAt = DateTime.UtcNow;

        await _templateRepository.UpdateAsync(template);
        await LogAdminActionAsync(adminId, "UPDATE_NOTIFICATION_TEMPLATE", "NotificationTemplate", template.Id.ToString(), null);

        return MapTemplateDto(template);
    }

    public async Task DeleteTemplateAsync(Guid adminId, Guid templateId)
    {
        var template = await _templateRepository.GetByIdAsync(templateId)
            ?? throw new KeyNotFoundException("Template not found.");

        await _templateRepository.DeleteAsync(template);
        await LogAdminActionAsync(adminId, "DELETE_NOTIFICATION_TEMPLATE", "NotificationTemplate", templateId.ToString(), null);
    }

    public async Task<NotificationTemplateListResponse> GetTemplatesAsync(int page = 1, int pageSize = 20, bool? isActive = null)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var (items, total) = await _templateRepository.GetPagedAsync(safePage, safePageSize, isActive);
        var totalPages = (int)Math.Ceiling(total / (double)safePageSize);

        return new NotificationTemplateListResponse(items.Select(MapTemplateDto), total, safePage, safePageSize, totalPages);
    }

    public async Task<NotificationScheduleDto> CreateScheduleAsync(Guid adminId, CreateNotificationScheduleRequest request)
    {
        ValidateSchedule(request.TargetScope, request.TargetUserId, request.ScheduledFor);

        var now = DateTime.UtcNow;
        var schedule = new NotificationSchedule
        {
            Id = Guid.NewGuid(),
            TemplateId = request.TemplateId,
            TargetUserId = request.TargetUserId,
            CreatedByAdminId = adminId,
            Type = request.Type,
            Source = NotificationSource.Scheduled,
            TargetScope = request.TargetScope,
            Recurrence = request.Recurrence,
            Status = NotificationScheduleStatus.Pending,
            Title = request.Title.Trim(),
            Message = request.Message.Trim(),
            MetadataJson = request.MetadataJson,
            ScheduledFor = request.ScheduledFor,
            Attempts = 0,
            CreatedAt = now,
            UpdatedAt = now
        };

        await _scheduleRepository.AddAsync(schedule);
        await LogAdminActionAsync(adminId, "CREATE_NOTIFICATION_SCHEDULE", "NotificationSchedule", schedule.Id.ToString(), null);

        return MapScheduleDto(schedule);
    }

    public async Task<NotificationScheduleDto> UpdateScheduleAsync(Guid adminId, Guid scheduleId, UpdateNotificationScheduleRequest request)
    {
        ValidateSchedule(request.TargetScope, request.TargetUserId, request.ScheduledFor);

        var schedule = await _scheduleRepository.GetByIdAsync(scheduleId)
            ?? throw new KeyNotFoundException("Schedule not found.");

        if (schedule.Status is NotificationScheduleStatus.Sent or NotificationScheduleStatus.Cancelled)
        {
            throw new InvalidOperationException("Cannot modify schedule that is already completed/cancelled.");
        }

        schedule.TemplateId = request.TemplateId;
        schedule.TargetUserId = request.TargetUserId;
        schedule.Type = request.Type;
        schedule.TargetScope = request.TargetScope;
        schedule.Recurrence = request.Recurrence;
        schedule.Title = request.Title.Trim();
        schedule.Message = request.Message.Trim();
        schedule.MetadataJson = request.MetadataJson;
        schedule.ScheduledFor = request.ScheduledFor;
        schedule.UpdatedAt = DateTime.UtcNow;

        await _scheduleRepository.UpdateAsync(schedule);
        await LogAdminActionAsync(adminId, "UPDATE_NOTIFICATION_SCHEDULE", "NotificationSchedule", schedule.Id.ToString(), null);

        return MapScheduleDto(schedule);
    }

    public async Task CancelScheduleAsync(Guid adminId, Guid scheduleId)
    {
        var schedule = await _scheduleRepository.GetByIdAsync(scheduleId)
            ?? throw new KeyNotFoundException("Schedule not found.");

        if (schedule.Status == NotificationScheduleStatus.Sent)
        {
            throw new InvalidOperationException("Cannot cancel a sent schedule.");
        }

        schedule.Status = NotificationScheduleStatus.Cancelled;
        schedule.UpdatedAt = DateTime.UtcNow;
        await _scheduleRepository.UpdateAsync(schedule);

        await LogAdminActionAsync(adminId, "CANCEL_NOTIFICATION_SCHEDULE", "NotificationSchedule", scheduleId.ToString(), null);
    }

    public async Task<NotificationScheduleListResponse> GetSchedulesAsync(int page = 1, int pageSize = 20, NotificationScheduleStatus? status = null)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var (items, total) = await _scheduleRepository.GetPagedAsync(safePage, safePageSize, status);
        var totalPages = (int)Math.Ceiling(total / (double)safePageSize);

        return new NotificationScheduleListResponse(items.Select(MapScheduleDto), total, safePage, safePageSize, totalPages);
    }

    public async Task<NotificationDeliveryLogListResponse> GetDeliveryLogsAsync(int page = 1, int pageSize = 20)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 200);

        var (items, total) = await _deliveryLogRepository.GetPagedAsync(safePage, safePageSize);
        var totalPages = (int)Math.Ceiling(total / (double)safePageSize);

        return new NotificationDeliveryLogListResponse(
            items.Select(x => new NotificationDeliveryLogDto(
                x.Id,
                x.NotificationId,
                x.ScheduleId,
                x.UserId,
                x.Channel,
                x.Status,
                x.ErrorMessage,
                x.DeliveredAt)),
            total,
            safePage,
            safePageSize,
            totalPages);
    }

    public Task<int> CleanupExpiredNotificationsAsync()
    {
        return _notificationRepository.CleanupExpiredAsync(DateTime.UtcNow);
    }

    public Task<NotificationDto> SendViolationWarningAsync(Guid adminId, Guid userId, string title, string message, string? metadataJson = null)
    {
        return SendToUserAsync(adminId, userId, NotificationType.ViolationWarning, NotificationSource.Automatic, title, message, metadataJson, null);
    }

    public Task<int> SendTrackUpdateBroadcastAsync(Guid adminId, string title, string message, string? metadataJson = null)
    {
        return SendBroadcastAsync(adminId, NotificationType.TrackUpdate, NotificationSource.Automatic, title, message, metadataJson, null);
    }

    private static NotificationDto MapNotificationDto(Notification item) => new(
        item.Id,
        item.Type,
        item.Source,
        item.Title,
        item.Message,
        item.MetadataJson,
        item.IsRead,
        item.CreatedAt,
        item.ReadAt,
        item.ExpiresAt
    );

    private static NotificationTemplateDto MapTemplateDto(NotificationTemplate template) => new(
        template.Id,
        template.Name,
        template.Type,
        template.TitleTemplate,
        template.MessageTemplate,
        template.MetadataTemplateJson,
        template.IsActive,
        template.CreatedByAdminId,
        template.CreatedAt,
        template.UpdatedAt
    );

    private static NotificationScheduleDto MapScheduleDto(NotificationSchedule schedule) => new(
        schedule.Id,
        schedule.TemplateId,
        schedule.TargetUserId,
        schedule.CreatedByAdminId,
        schedule.Type,
        schedule.Source,
        schedule.TargetScope,
        schedule.Recurrence,
        schedule.Status,
        schedule.Title,
        schedule.Message,
        schedule.MetadataJson,
        schedule.ScheduledFor,
        schedule.ProcessedAt,
        schedule.Attempts,
        schedule.LastError,
        schedule.CreatedAt,
        schedule.UpdatedAt
    );

    private static void ValidateSchedule(NotificationTargetScope targetScope, Guid? targetUserId, DateTime scheduledFor)
    {
        if (scheduledFor <= DateTime.UtcNow)
        {
            throw new ArgumentException("Scheduled time must be in the future.");
        }

        if (targetScope == NotificationTargetScope.User && !targetUserId.HasValue)
        {
            throw new ArgumentException("TargetUserId is required when target scope is User.");
        }

        if (targetScope == NotificationTargetScope.AllUsers && targetUserId.HasValue)
        {
            throw new ArgumentException("TargetUserId must be null when target scope is AllUsers.");
        }
    }

    private async Task LogAdminActionAsync(Guid adminId, string action, string? targetType, string? targetId, string? details)
    {
        await _adminAuditLogRepository.AddAsync(new AdminAuditLog
        {
            Id = Guid.NewGuid(),
            AdminId = adminId,
            Action = action,
            TargetType = targetType,
            TargetId = targetId,
            Details = details,
            CreatedAt = DateTime.UtcNow
        });
    }
}
