using Application.Abstractions.Admin;
using Application.Interfaces;
using Application.Interfaces.Repositories;
using Application.Interfaces.Services;
using Application.Services;
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
    public static IServiceCollection AddInfrastructure(this IServiceCollection services , IConfiguration configuration)
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
        services.AddScoped<IArtistRepository, ArtistRepository>();
        services.AddScoped<IAlbumRepository, AlbumRepository>();
        services.AddScoped<IAdminAuditLogRepository, AdminAuditLogRepository>();
        services.AddScoped<IAdminAnalyticsRepository, AdminAnalyticsRepository>();
        services.AddScoped<ICommentRepository, CommentRepository>();
        services.AddScoped<IWaitlistRepository, WaitlistRepository>();
        services.AddScoped<ISubscriptionRepository, SubscriptionRepository>();
        services.AddScoped<IPaymentTransactionRepository, PaymentTransactionRepository>();
        services.AddScoped<WaitlistService>();
        // admin
        services.AddScoped<IAdminDashboardRepository, AdminDashboardRepository>();

        // External API clients — 10 s timeout so slow providers fail fast
        services.AddHttpClient<IAudiusApiClient, AudiusApiClient>()
            .ConfigureHttpClient(c => c.Timeout = TimeSpan.FromSeconds(10));
        services.AddHttpClient<IDeezerApiClient, DeezerApiClient>()
            .ConfigureHttpClient(c => c.Timeout = TimeSpan.FromSeconds(10));
        services.AddHttpClient<IJamendoApiClient, JamendoApiClient>()
            .ConfigureHttpClient(c => c.Timeout = TimeSpan.FromSeconds(10));
        services.AddHttpClient<ILyricsApiClient, LyricsApiClient>();

        // Services
        services.AddScoped<IJwtService , JwtService>();
        services.AddScoped<IPasswordHasher , BcryptPasswordHasher>();
        //  admin
        services.AddScoped<IAdminDashboardService , AdminDashboardService>();
        services.AddScoped<IAdminDashboardDateRangeService , AdminDashboardDateRangeService>();

        return services;
    }
}
