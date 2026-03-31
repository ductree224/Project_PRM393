using Application.DTOs.Notifications;
using Application.Interfaces;
using Application.Interfaces.Services;
using Domain.Entities;
using Domain.Enums;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Services;

public class NotificationService : INotificationService
{
    private readonly SoundtiloDbContext _context;
    private readonly INotificationRealtimePublisher _realtime;

    public NotificationService(
        SoundtiloDbContext context ,
        INotificationRealtimePublisher realtime)
    {
        _context = context;
        _realtime = realtime;
    }

    // ================================
    // USER CREATE FEEDBACK → NOTIFY ADMIN
    // ================================
    public async Task NotifyAdminNewFeedbackAsync(Feedback feedback , CancellationToken ct = default)
    {
        var admins = await _context.Users
            .Where(x => x.Role == "admin")
            .Select(x => x.Id)
            .ToListAsync(ct);

        var notifications = new List<Notification>();

        foreach ( var adminId in admins )
        {
            var notification = new Notification
            {
                Id = Guid.NewGuid() ,
                UserId = adminId ,
                Type = NotificationType.SystemAnnouncement ,
                Source = NotificationSource.Automatic ,
                Title = "New Feedback" ,
                Message = $"New feedback: {feedback.Title}" ,
                CreatedAt = DateTime.UtcNow
            };

            notifications.Add(notification);
        }

        await _context.Notifications.AddRangeAsync(notifications , ct);
        await _context.SaveChangesAsync(ct);

        // REALTIME PUSH
        foreach ( var n in notifications )
        {
            var dto = new NotificationDto(
                n.Id ,
                n.Type ,
                n.Source ,
                n.Title ,
                n.Message ,
                null ,              // MetadataJson
                false ,             // IsRead
                n.CreatedAt ,
                null ,              // ReadAt
                null               // ExpiresAt
            );

            await _realtime.PublishToUserAsync(n.UserId , dto , ct);
        }
    }

    // ================================
    // ADMIN HANDLE → NOTIFY USER
    // ================================
    public async Task NotifyUserFeedbackHandledAsync(Feedback feedback , CancellationToken ct = default)
    {
        var notification = new Notification
        {
            Id = Guid.NewGuid() ,
            UserId = feedback.UserId ,
            Type = NotificationType.UserMessage ,
            Source = NotificationSource.Automatic ,
            Title = "Phản hồi đã được xử lý" ,
            Message = $"Phản hồi \"{feedback.Title}\": đã được ghi nhận xử lý." ,
            CreatedAt = DateTime.UtcNow
        };

        await _context.Notifications.AddAsync(notification , ct);
        await _context.SaveChangesAsync(ct);

        // REALTIME PUSH
        var dto = new NotificationDto(
            notification.Id ,
            notification.Type ,
            notification.Source ,
            notification.Title ,
            notification.Message ,
            null ,
            false ,
            notification.CreatedAt ,
            null ,
            null
        );

        await _realtime.PublishToUserAsync(notification.UserId , dto , ct);
    }

    public async Task<int> CleanupExpiredNotificationsAsync(CancellationToken ct = default)
    {
        var now = DateTime.UtcNow;

        var expired = await _context.Notifications
            .Where(x => x.ExpiresAt != null && x.ExpiresAt < now)
            .ToListAsync(ct);

        if ( !expired.Any() )
            return 0;

        _context.Notifications.RemoveRange(expired);

        var affected = await _context.SaveChangesAsync(ct);

        return affected;
    }
}