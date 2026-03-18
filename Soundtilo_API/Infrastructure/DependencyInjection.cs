using Application.Interfaces;
using Domain.Interfaces;
using Infrastructure.Data;
using Infrastructure.ExternalApis;
using Infrastructure.Repositories;
using Infrastructure.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(this IServiceCollection services, IConfiguration configuration)
    {
        // Database
        services.AddDbContext<SoundtiloDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("DefaultConnection")));

        // Repositories
        services.AddScoped<IUserRepository, UserRepository>();
        services.AddScoped<ITrackCacheRepository, TrackCacheRepository>();
        services.AddScoped<IPlaylistRepository, PlaylistRepository>();
        services.AddScoped<IFavoriteRepository, FavoriteRepository>();
        services.AddScoped<IHistoryRepository, HistoryRepository>();
        services.AddScoped<IRefreshTokenRepository, RefreshTokenRepository>();
        services.AddScoped<IPasswordResetTokenRepository, PasswordResetTokenRepository>();

        // External API clients
        services.AddHttpClient<IAudiusApiClient, AudiusApiClient>();
        services.AddHttpClient<IDeezerApiClient, DeezerApiClient>();
        services.AddHttpClient<IJamendoApiClient, JamendoApiClient>();
        services.AddHttpClient<ILyricsApiClient, LyricsApiClient>();

        // Services
        services.AddScoped<IJwtService, JwtService>();
        services.AddScoped<IPasswordHasher, BcryptPasswordHasher>();

        return services;
    }
}
