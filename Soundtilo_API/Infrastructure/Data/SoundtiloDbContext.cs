using Domain.Entities;
using Domain.Enums;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Data;

public class SoundtiloDbContext : DbContext
{
    public SoundtiloDbContext(DbContextOptions<SoundtiloDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<CachedTrack> CachedTracks => Set<CachedTrack>();
    public DbSet<Playlist> Playlists => Set<Playlist>();
    public DbSet<PlaylistTrack> PlaylistTracks => Set<PlaylistTrack>();
    public DbSet<AlbumTrack> AlbumTracks => Set<AlbumTrack>();
    public DbSet<Favorite> Favorites => Set<Favorite>();
    public DbSet<Feedback> Feedbacks => Set<Feedback>();
    public DbSet<ListeningHistory> ListeningHistories => Set<ListeningHistory>();
    public DbSet<UserSetting> UserSettings => Set<UserSetting>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();
    public DbSet<AdminAuditLog> AdminAuditLogs => Set<AdminAuditLog>();
    public DbSet<Comment> Comments => Set<Comment>();
    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<NotificationTemplate> NotificationTemplates => Set<NotificationTemplate>();
    public DbSet<NotificationSchedule> NotificationSchedules => Set<NotificationSchedule>();
    public DbSet<NotificationDeliveryLog> NotificationDeliveryLogs => Set<NotificationDeliveryLog>();
    public DbSet<Waitlist> Waitlists { get; set; }
    public DbSet<WaitlistTrack> WaitlistTracks { get; set; }
    public DbSet<Artist> Artists => Set<Artist>();
    public DbSet<Album> Albums => Set<Album>();
    public DbSet<SubscriptionPlan> SubscriptionPlans => Set<SubscriptionPlan>();
    public DbSet<Subscription> Subscriptions => Set<Subscription>();
    public DbSet<PaymentTransaction> PaymentTransactions => Set<PaymentTransaction>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // User
        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("users");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Username).HasColumnName("username").HasMaxLength(50).IsRequired();
            entity.Property(e => e.Email).HasColumnName("email").HasMaxLength(255).IsRequired();
            entity.Property(e => e.PasswordHash).HasColumnName("password_hash").HasMaxLength(255).IsRequired();
            entity.Property(e => e.DisplayName).HasColumnName("display_name").HasMaxLength(100);
            entity.Property(e => e.AvatarUrl).HasColumnName("avatar_url");
            entity.Property(e => e.Role).HasColumnName("role").HasMaxLength(20).HasDefaultValue("user");
            entity.Property(e => e.IsBanned).HasColumnName("is_banned").HasDefaultValue(false);
            entity.Property(e => e.BannedAt).HasColumnName("banned_at");
            entity.Property(e => e.BannedReason).HasColumnName("banned_reason");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.HasIndex(e => e.Username).IsUnique();
            entity.HasIndex(e => e.Email).IsUnique();
            entity.HasIndex(e => e.Role);
            entity.Property(e => e.SubscriptionTier).HasColumnName("subscription_tier").HasMaxLength(20).HasDefaultValue("free");
            entity.Property(e => e.PremiumExpiresAt).HasColumnName("premium_expires_at");
            entity.Property(e => e.StripeCustomerId).HasColumnName("stripe_customer_id").HasMaxLength(255);
            entity.HasIndex(e => e.SubscriptionTier);
            entity.Property(e => e.SubscriptionTier).HasColumnName("subscription_tier").HasMaxLength(20).HasDefaultValue("free");
            entity.Property(e => e.PremiumExpiresAt).HasColumnName("premium_expires_at");
            entity.Property(e => e.StripeCustomerId).HasColumnName("stripe_customer_id").HasMaxLength(255);
            entity.HasIndex(e => e.SubscriptionTier);
        });

        // Artist
        modelBuilder.Entity<Artist>(entity =>
        {
            entity.ToTable("artists");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.ExternalId).HasColumnName("external_id").HasMaxLength(255);
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(255).IsRequired();
            entity.Property(e => e.Bio).HasColumnName("bio");
            entity.Property(e => e.ImageUrl).HasColumnName("image_url");
            entity.Property(e => e.Tags).HasColumnName("tags").HasColumnType("text[]");
            entity.Property(e => e.IsOverride).HasColumnName("is_override").HasDefaultValue(false);
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.HasIndex(e => e.ExternalId);
        });

        // Album
        modelBuilder.Entity<Album>(entity =>
        {
            entity.ToTable("albums");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.ExternalId).HasColumnName("external_id").HasMaxLength(255);
            entity.Property(e => e.ArtistId).HasColumnName("artist_id");
            entity.Property(e => e.Title).HasColumnName("title").HasMaxLength(255).IsRequired();
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.ReleaseDate).HasColumnName("release_date");
            entity.Property(e => e.CoverImageUrl).HasColumnName("cover_image_url");
            entity.Property(e => e.Tags).HasColumnName("tags").HasColumnType("text[]");
            entity.Property(e => e.IsOverride).HasColumnName("is_override").HasDefaultValue(false);
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");

            entity.HasOne(e => e.Artist).WithMany(a => a.Albums).HasForeignKey(e => e.ArtistId).OnDelete(DeleteBehavior.SetNull);
            entity.HasIndex(e => e.ExternalId);
        });

        // CachedTrack
        modelBuilder.Entity<CachedTrack>(entity =>
        {
            entity.ToTable("cached_tracks");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.ExternalId).HasColumnName("external_id").HasMaxLength(255).IsRequired();
            entity.Property(e => e.Source).HasColumnName("source").HasMaxLength(50);
            entity.Property(e => e.Title).HasColumnName("title").HasMaxLength(500).IsRequired();
            entity.Property(e => e.ArtistName).HasColumnName("artist_name").HasMaxLength(255).IsRequired();
            entity.Property(e => e.AlbumName).HasColumnName("album_name").HasMaxLength(255);
            entity.Property(e => e.ArtworkUrl).HasColumnName("artwork_url");
            entity.Property(e => e.StreamUrl).HasColumnName("stream_url");
            entity.Property(e => e.PreviewUrl).HasColumnName("preview_url");
            entity.Property(e => e.DurationSeconds).HasColumnName("duration_seconds");
            entity.Property(e => e.Genre).HasColumnName("genre").HasMaxLength(100);
            entity.Property(e => e.Mood).HasColumnName("mood").HasMaxLength(100);
            entity.Property(e => e.PlayCount).HasColumnName("play_count");
            entity.Property(e => e.Status).HasColumnName("status").HasDefaultValue(Domain.Enums.TrackStatus.Active);
            entity.Property(e => e.ExternalData).HasColumnName("external_data").HasColumnType("jsonb");
            entity.Property(e => e.CachedAt).HasColumnName("cached_at");
            entity.Property(e => e.ExpiresAt).HasColumnName("expires_at");
            entity.HasIndex(e => e.ExternalId).IsUnique();
        });

        // Playlist
        modelBuilder.Entity<Playlist>(entity =>
        {
            entity.ToTable("playlists");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(255).IsRequired();
            entity.Property(e => e.Description).HasColumnName("description");
            entity.Property(e => e.CoverImageUrl).HasColumnName("cover_image_url");
            entity.Property(e => e.IsPublic).HasColumnName("is_public");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.HasOne(e => e.User).WithMany(u => u.Playlists).HasForeignKey(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
        });

        // AlbumTrack
        modelBuilder.Entity<AlbumTrack>(entity =>
        {
            entity.ToTable("album_tracks");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.AlbumId).HasColumnName("album_id");
            entity.Property(e => e.TrackExternalId).HasColumnName("track_external_id").HasMaxLength(255).IsRequired();
            entity.Property(e => e.Position).HasColumnName("position");
            entity.Property(e => e.AddedAt).HasColumnName("added_at");
            entity.HasOne(e => e.Album).WithMany(a => a.AlbumTracks).HasForeignKey(e => e.AlbumId).OnDelete(DeleteBehavior.Cascade);
            entity.HasIndex(e => new { e.AlbumId , e.TrackExternalId }).IsUnique();
        });

        // PlaylistTrack
        modelBuilder.Entity<PlaylistTrack>(entity =>
        {
            entity.ToTable("playlist_tracks");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.PlaylistId).HasColumnName("playlist_id");
            entity.Property(e => e.TrackExternalId).HasColumnName("track_external_id").HasMaxLength(255).IsRequired();
            entity.Property(e => e.Position).HasColumnName("position");
            entity.Property(e => e.AddedAt).HasColumnName("added_at");
            entity.HasOne(e => e.Playlist).WithMany(p => p.PlaylistTracks).HasForeignKey(e => e.PlaylistId).OnDelete(DeleteBehavior.Cascade);
            entity.HasIndex(e => new { e.PlaylistId , e.TrackExternalId }).IsUnique();
        });

        // Favorite
        modelBuilder.Entity<Favorite>(entity =>
        {
            entity.ToTable("favorites");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.TrackExternalId).HasColumnName("track_external_id").HasMaxLength(255).IsRequired();
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.User).WithMany(u => u.Favorites).HasForeignKey(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasIndex(e => new { e.UserId , e.TrackExternalId }).IsUnique();
        });

        //  feeedback
        modelBuilder.Entity<Feedback>(entity =>
        {
            entity.ToTable("feedbacks");

            entity.HasKey(e => e.Id);

            entity.Property(e => e.UserId).HasColumnName("user_id");
            //entity.Property(e => e.Type).HasColumnName("type").HasMaxLength(50);
            entity.Property(e => e.Category).HasColumnName("category").HasMaxLength(50);
            entity.Property(e => e.Priority).HasColumnName("priority").HasMaxLength(50);
            entity.Property(e => e.Title).HasColumnName("title").HasMaxLength(200);
            entity.Property(e => e.Content).HasColumnName("content").HasMaxLength(2000);
            entity.Property(e => e.Status)
                  .HasColumnName("status")
                  .HasMaxLength(50)
                  .HasDefaultValue("pending");
            entity.Property(e => e.AdminReply).HasColumnName("admin_reply");
            entity.Property(e => e.HandledByAdminId).HasColumnName("handled_by_admin_id");
            entity.Property(e => e.CreatedAt)
                  .HasColumnName("created_at")
                  .HasDefaultValueSql("NOW()");
            entity.Property(e => e.HandledAt).HasColumnName("handled_at");
            entity.Property(e => e.DeviceInfo)
                  .HasColumnName("device_info")
                  .HasMaxLength(255);

            entity.Property(e => e.AppVersion)
                  .HasColumnName("app_version")
                  .HasMaxLength(50);

            entity.Property(e => e.Platform)
                  .HasColumnName("platform")
                  .HasMaxLength(50);

            entity.Property(e => e.AttachmentUrl)
                  .HasColumnName("attachment_url");

            entity.HasOne(e => e.User)
                  .WithMany()
                  .HasForeignKey(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(e => new { e.Status , e.CreatedAt });
            entity.HasIndex(e => e.Category);
            entity.HasIndex(e => e.Priority);

        });

        // ListeningHistory
        modelBuilder.Entity<ListeningHistory>(entity =>
        {
            entity.ToTable("listening_history");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.TrackExternalId).HasColumnName("track_external_id").HasMaxLength(255).IsRequired();
            entity.Property(e => e.ListenedAt).HasColumnName("listened_at");
            entity.Property(e => e.DurationListened).HasColumnName("duration_listened");
            entity.Property(e => e.Completed).HasColumnName("completed");
            entity.HasOne(e => e.User).WithMany(u => u.ListeningHistories).HasForeignKey(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasIndex(e => new { e.UserId , e.ListenedAt });
        });

        // UserSetting
        modelBuilder.Entity<UserSetting>(entity =>
        {
            entity.ToTable("user_settings");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.ThemeMode).HasColumnName("theme_mode").HasMaxLength(20);
            entity.Property(e => e.AudioQuality).HasColumnName("audio_quality").HasMaxLength(20);
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");
            entity.HasOne(e => e.User).WithOne(u => u.UserSetting).HasForeignKey<UserSetting>(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasIndex(e => e.UserId).IsUnique();
        });

        // RefreshToken
        modelBuilder.Entity<RefreshToken>(entity =>
        {
            entity.ToTable("refresh_tokens");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Token).HasColumnName("token").HasMaxLength(500).IsRequired();
            entity.Property(e => e.ExpiresAt).HasColumnName("expires_at");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.RevokedAt).HasColumnName("revoked_at");
            entity.HasOne(e => e.User).WithMany(u => u.RefreshTokens).HasForeignKey(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasIndex(e => e.Token).IsUnique();
        });

        // PasswordResetToken
        modelBuilder.Entity<PasswordResetToken>(entity =>
        {
            entity.ToTable("password_reset_tokens");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Token).HasColumnName("token").HasMaxLength(500).IsRequired();
            entity.Property(e => e.ExpiresAt).HasColumnName("expires_at");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UsedAt).HasColumnName("used_at");
            entity.HasOne(e => e.User).WithMany(u => u.PasswordResetTokens).HasForeignKey(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasIndex(e => e.Token).IsUnique();
        });

        // AdminAuditLog
        modelBuilder.Entity<AdminAuditLog>(entity =>
        {
            entity.ToTable("admin_audit_logs");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.AdminId).HasColumnName("admin_id");
            entity.Property(e => e.Action).HasColumnName("action").HasMaxLength(100).IsRequired();
            entity.Property(e => e.TargetType).HasColumnName("target_type").HasMaxLength(50);
            entity.Property(e => e.TargetId).HasColumnName("target_id").HasMaxLength(255);
            entity.Property(e => e.Details).HasColumnName("details").HasColumnType("jsonb");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.Admin).WithMany(u => u.AdminAuditLogs).HasForeignKey(e => e.AdminId).OnDelete(DeleteBehavior.Cascade);
            entity.HasIndex(e => e.AdminId);
            entity.HasIndex(e => e.CreatedAt);
        });

        // Comment
        modelBuilder.Entity<Comment>(entity =>
        {
            entity.ToTable("comments");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.TrackExternalId).HasColumnName("track_external_id").HasMaxLength(255).IsRequired();
            entity.Property(e => e.Content).HasColumnName("content").HasMaxLength(500).IsRequired();
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.User).WithMany(u => u.Comments).HasForeignKey(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasIndex(e => new { e.TrackExternalId , e.CreatedAt });
        });

        // Notification
        modelBuilder.Entity<Notification>(entity =>
        {
            entity.ToTable("notifications");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.CreatedByAdminId).HasColumnName("created_by_admin_id");
            entity.Property(e => e.Type).HasColumnName("type").HasConversion<string>().HasMaxLength(50).IsRequired();
            entity.Property(e => e.Source).HasColumnName("source").HasConversion<string>().HasMaxLength(50).IsRequired();
            entity.Property(e => e.Title).HasColumnName("title").HasMaxLength(200).IsRequired();
            entity.Property(e => e.Message).HasColumnName("message").HasMaxLength(2000).IsRequired();
            entity.Property(e => e.MetadataJson).HasColumnName("metadata_json").HasColumnType("jsonb");
            entity.Property(e => e.IsRead).HasColumnName("is_read").HasDefaultValue(false);
            entity.Property(e => e.ReadAt).HasColumnName("read_at");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.ExpiresAt).HasColumnName("expires_at");

            entity.HasOne(e => e.User)
                .WithMany(u => u.Notifications)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasOne(e => e.CreatedByAdmin)
                .WithMany()
                .HasForeignKey(e => e.CreatedByAdminId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasIndex(e => new { e.UserId , e.IsRead , e.CreatedAt });
            entity.HasIndex(e => e.ExpiresAt);
        });

        // NotificationTemplate
        modelBuilder.Entity<NotificationTemplate>(entity =>
        {
            entity.ToTable("notification_templates");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(120).IsRequired();
            entity.Property(e => e.Type).HasColumnName("type").HasConversion<string>().HasMaxLength(50).IsRequired();
            entity.Property(e => e.TitleTemplate).HasColumnName("title_template").HasMaxLength(200).IsRequired();
            entity.Property(e => e.MessageTemplate).HasColumnName("message_template").HasMaxLength(2000).IsRequired();
            entity.Property(e => e.MetadataTemplateJson).HasColumnName("metadata_template_json").HasColumnType("jsonb");
            entity.Property(e => e.IsActive).HasColumnName("is_active").HasDefaultValue(true);
            entity.Property(e => e.CreatedByAdminId).HasColumnName("created_by_admin_id");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");

            entity.HasOne(e => e.CreatedByAdmin)
                .WithMany(u => u.NotificationTemplatesCreated)
                .HasForeignKey(e => e.CreatedByAdminId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasIndex(e => e.Name).IsUnique();
            entity.HasIndex(e => new { e.IsActive , e.UpdatedAt });
        });

        // NotificationSchedule
        modelBuilder.Entity<NotificationSchedule>(entity =>
        {
            entity.ToTable("notification_schedules");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.TemplateId).HasColumnName("template_id");
            entity.Property(e => e.TargetUserId).HasColumnName("target_user_id");
            entity.Property(e => e.CreatedByAdminId).HasColumnName("created_by_admin_id");
            entity.Property(e => e.Type).HasColumnName("type").HasConversion<string>().HasMaxLength(50).IsRequired();
            entity.Property(e => e.Source).HasColumnName("source").HasConversion<string>().HasMaxLength(50).IsRequired();
            entity.Property(e => e.TargetScope).HasColumnName("target_scope").HasConversion<string>().HasMaxLength(50).IsRequired();
            entity.Property(e => e.Recurrence).HasColumnName("recurrence").HasConversion<string>().HasMaxLength(50).IsRequired().HasDefaultValue(NotificationRecurrence.OneTime);
            entity.Property(e => e.Status).HasColumnName("status").HasConversion<string>().HasMaxLength(50).IsRequired();
            entity.Property(e => e.Title).HasColumnName("title").HasMaxLength(200).IsRequired();
            entity.Property(e => e.Message).HasColumnName("message").HasMaxLength(2000).IsRequired();
            entity.Property(e => e.MetadataJson).HasColumnName("metadata_json").HasColumnType("jsonb");
            entity.Property(e => e.ScheduledFor).HasColumnName("scheduled_for");
            entity.Property(e => e.ProcessedAt).HasColumnName("processed_at");
            entity.Property(e => e.Attempts).HasColumnName("attempts").HasDefaultValue(0);
            entity.Property(e => e.LastError).HasColumnName("last_error").HasMaxLength(1500);
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.Property(e => e.UpdatedAt).HasColumnName("updated_at");

            entity.HasOne(e => e.Template)
                .WithMany(t => t.Schedules)
                .HasForeignKey(e => e.TemplateId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(e => e.TargetUser)
                .WithMany(u => u.NotificationSchedulesTargeted)
                .HasForeignKey(e => e.TargetUserId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(e => e.CreatedByAdmin)
                .WithMany(u => u.NotificationSchedulesCreated)
                .HasForeignKey(e => e.CreatedByAdminId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(e => new { e.Status , e.ScheduledFor });
            entity.HasIndex(e => e.TargetUserId);
        });

        // NotificationDeliveryLog
        modelBuilder.Entity<NotificationDeliveryLog>(entity =>
        {
            entity.ToTable("notification_delivery_logs");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.NotificationId).HasColumnName("notification_id");
            entity.Property(e => e.ScheduleId).HasColumnName("schedule_id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.Channel).HasColumnName("channel").HasMaxLength(50).IsRequired();
            entity.Property(e => e.Status).HasColumnName("status").HasMaxLength(50).IsRequired();
            entity.Property(e => e.ErrorMessage).HasColumnName("error_message").HasMaxLength(1500);
            entity.Property(e => e.DeliveredAt).HasColumnName("delivered_at");

            entity.HasOne(e => e.Notification)
                .WithMany(n => n.DeliveryLogs)
                .HasForeignKey(e => e.NotificationId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(e => e.Schedule)
                .WithMany(s => s.DeliveryLogs)
                .HasForeignKey(e => e.ScheduleId)
                .OnDelete(DeleteBehavior.SetNull);

            entity.HasOne(e => e.User)
                .WithMany(u => u.NotificationDeliveryLogs)
                .HasForeignKey(e => e.UserId)
                .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(e => e.DeliveredAt);
            entity.HasIndex(e => new { e.UserId , e.DeliveredAt });
        });
        // Cấu hình khóa chính kép cho WaitlistTrack
        // Waitlist
        modelBuilder.Entity<Waitlist>(entity =>
        {
            entity.ToTable("Waitlists");
            entity.HasKey(e => e.Id);

            // SỬA Ở ĐÂY: Viết hoa y hệt trên Supabase
            entity.Property(e => e.Id).HasColumnName("Id");
            entity.Property(e => e.UserId).HasColumnName("UserId");
            entity.Property(e => e.CreatedAt).HasColumnName("CreatedAt");
            entity.Property(e => e.UpdatedAt).HasColumnName("UpdatedAt");

            // Cấu hình quan hệ 1-1 giữa User và Waitlist
            entity.HasOne(e => e.User)
                  .WithOne()
                  .HasForeignKey<Waitlist>(e => e.UserId)
                  .OnDelete(DeleteBehavior.Cascade);

            entity.HasIndex(e => e.UserId).IsUnique();
        });

        // WaitlistTrack
        modelBuilder.Entity<WaitlistTrack>(entity =>
        {
            entity.ToTable("WaitlistTracks");
            // Cấu hình khóa chính kép
            entity.HasKey(e => new { e.WaitlistId , e.TrackExternalId });

            // SỬA Ở ĐÂY: Viết hoa y hệt trên Supabase
            entity.Property(e => e.WaitlistId).HasColumnName("WaitlistId");
            entity.Property(e => e.TrackExternalId).HasColumnName("TrackExternalId").HasMaxLength(255).IsRequired();
            entity.Property(e => e.Position).HasColumnName("Position");
            entity.Property(e => e.AddedAt).HasColumnName("AddedAt");

            entity.HasOne(e => e.Waitlist)
                  .WithMany(w => w.Tracks)
                  .HasForeignKey(e => e.WaitlistId)
                  .OnDelete(DeleteBehavior.Cascade);
        });

        // SubscriptionPlan
        modelBuilder.Entity<SubscriptionPlan>(entity =>
        {
            entity.ToTable("subscription_plans");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.Name).HasColumnName("name").HasMaxLength(100).IsRequired();
            entity.Property(e => e.Price).HasColumnName("price").HasColumnType("decimal(10,2)");
            entity.Property(e => e.Interval).HasColumnName("interval").HasMaxLength(20).IsRequired();
            entity.Property(e => e.StripePriceId).HasColumnName("stripe_price_id").HasMaxLength(255);
            entity.Property(e => e.Currency).HasColumnName("currency").HasMaxLength(10).HasDefaultValue("vnd");
            entity.Property(e => e.IsActive).HasColumnName("is_active").HasDefaultValue(true);
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
        });

        // Subscription
        modelBuilder.Entity<Subscription>(entity =>
        {
            entity.ToTable("subscriptions");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.PlanId).HasColumnName("plan_id");
            entity.Property(e => e.StripeSubscriptionId).HasColumnName("stripe_subscription_id").HasMaxLength(255);
            entity.Property(e => e.Status).HasColumnName("status").HasMaxLength(30).HasDefaultValue("active");
            entity.Property(e => e.CurrentPeriodStart).HasColumnName("current_period_start");
            entity.Property(e => e.CurrentPeriodEnd).HasColumnName("current_period_end");
            entity.Property(e => e.CancelledAt).HasColumnName("cancelled_at");
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.User).WithOne(u => u.Subscription).HasForeignKey<Subscription>(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(e => e.Plan).WithMany(p => p.Subscriptions).HasForeignKey(e => e.PlanId).OnDelete(DeleteBehavior.Restrict);
            entity.HasIndex(e => e.UserId).IsUnique();
            entity.HasIndex(e => e.StripeSubscriptionId);
        });

        // PaymentTransaction
        modelBuilder.Entity<PaymentTransaction>(entity =>
        {
            entity.ToTable("payment_transactions");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Id).HasColumnName("id");
            entity.Property(e => e.UserId).HasColumnName("user_id");
            entity.Property(e => e.SubscriptionId).HasColumnName("subscription_id");
            entity.Property(e => e.StripePaymentIntentId).HasColumnName("stripe_payment_intent_id").HasMaxLength(255);
            entity.Property(e => e.StripeInvoiceId).HasColumnName("stripe_invoice_id").HasMaxLength(255);
            entity.Property(e => e.Amount).HasColumnName("amount").HasColumnType("decimal(10,2)");
            entity.Property(e => e.Currency).HasColumnName("currency").HasMaxLength(10).HasDefaultValue("vnd");
            entity.Property(e => e.Status).HasColumnName("status").HasMaxLength(20).IsRequired();
            entity.Property(e => e.CreatedAt).HasColumnName("created_at");
            entity.HasOne(e => e.User).WithMany(u => u.PaymentTransactions).HasForeignKey(e => e.UserId).OnDelete(DeleteBehavior.Cascade);
            entity.HasOne(e => e.Subscription).WithMany(s => s.PaymentTransactions).HasForeignKey(e => e.SubscriptionId).OnDelete(DeleteBehavior.SetNull);
            entity.HasIndex(e => e.UserId);
            entity.HasIndex(e => e.CreatedAt);
        });
    }
}
