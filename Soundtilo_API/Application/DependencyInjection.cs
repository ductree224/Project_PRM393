using Application.Interfaces.Services;
using Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<AuthService>();
        services.AddScoped<NotificationService>();
        services.AddScoped<NotificationSchedulerService>();
        services.AddScoped<Interfaces.ITrackService, TrackService>();
        services.AddScoped<TrackService>(); // Keep concrete registration to avoid breaking existing controllers if needed
        services.AddScoped<PlaylistService>();
        services.AddScoped<FavoriteService>();
        services.AddScoped<HistoryService>();
        services.AddScoped<LyricsService>();
        services.AddScoped<UserService>();

        services.AddScoped<AdminService>();
        services.AddScoped<CommentService>();
        services.AddScoped<SubscriptionService>();
        services.AddScoped<SubscriptionExpiryNotificationService>();

        services.AddScoped<Interfaces.IArtistService, ArtistService>();
        services.AddScoped<Interfaces.IAlbumService, AlbumService>();

        return services;
    }
}
