using Application.Services;
using Microsoft.Extensions.DependencyInjection;

namespace Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(this IServiceCollection services)
    {
        services.AddScoped<AuthService>();
        services.AddScoped<Interfaces.ITrackService, TrackService>();
        services.AddScoped<TrackService>(); // Keep concrete registration to avoid breaking existing controllers if needed
        services.AddScoped<PlaylistService>();
        services.AddScoped<FavoriteService>();
        services.AddScoped<HistoryService>();
        services.AddScoped<LyricsService>();
        services.AddScoped<UserService>();
        services.AddScoped<Interfaces.IArtistService, ArtistService>();
        services.AddScoped<Interfaces.IAlbumService, AlbumService>();

        return services;
    }
}
