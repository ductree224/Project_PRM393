using Domain.Entities;
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
    public DbSet<ListeningHistory> ListeningHistories => Set<ListeningHistory>();
    public DbSet<UserSetting> UserSettings => Set<UserSetting>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<PasswordResetToken> PasswordResetTokens => Set<PasswordResetToken>();
    public DbSet<AdminAuditLog> AdminAuditLogs => Set<AdminAuditLog>();
    public DbSet<Comment> Comments => Set<Comment>();
    public DbSet<Waitlist> Waitlists { get; set; }
    public DbSet<WaitlistTrack> WaitlistTracks { get; set; }
    public DbSet<Artist> Artists => Set<Artist>();
    public DbSet<Album> Albums => Set<Album>();

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
            entity.HasIndex(e => new { e.AlbumId, e.TrackExternalId }).IsUnique();
        });

        // PlaylistTrack

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
            entity.HasIndex(e => new { e.UserId, e.TrackExternalId }).IsUnique();
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
            entity.HasIndex(e => new { e.UserId, e.ListenedAt });
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
            entity.HasIndex(e => new { e.TrackExternalId, e.CreatedAt });
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
            entity.HasKey(e => new { e.WaitlistId, e.TrackExternalId });

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
    }
}
