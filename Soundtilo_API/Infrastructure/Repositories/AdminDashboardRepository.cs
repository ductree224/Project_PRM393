using Application.DTOs.Admin;
using Application.Interfaces.Repositories;
using Domain.Entities;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Repositories;

public class AdminDashboardRepository : GenericRepository<User>, IAdminDashboardRepository
{
    private readonly SoundtiloDbContext _context;

    public AdminDashboardRepository(SoundtiloDbContext context) : base(context)
    {
        _context = context;
    }

    public async Task<AdminDashboardSummaryResponse> GetSummaryAsync(
        string timeZoneId ,
        CancellationToken cancellationToken = default)
    {
        var totalUsers = await _context.Users.LongCountAsync(cancellationToken);
        var totalPlayCount = await _context.ListeningHistories.LongCountAsync(cancellationToken);

        var activeCachedTracks = await _context.CachedTracks
            .LongCountAsync(x => x.ExpiresAt > DateTime.UtcNow , cancellationToken);

        var timeZone = TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
        var localNow = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow , timeZone);
        var localTodayStart = new DateTime(localNow.Year , localNow.Month , localNow.Day , 0 , 0 , 0 , DateTimeKind.Unspecified);
        var localTomorrowStart = localTodayStart.AddDays(1);

        var todayStartUtc = TimeZoneInfo.ConvertTimeToUtc(localTodayStart , timeZone);
        var tomorrowStartUtc = TimeZoneInfo.ConvertTimeToUtc(localTomorrowStart , timeZone);

        var newUsersToday = await _context.Users.LongCountAsync(
            x => x.CreatedAt >= todayStartUtc && x.CreatedAt < tomorrowStartUtc ,
            cancellationToken);

        return new AdminDashboardSummaryResponse
        {
            TotalUsers = totalUsers ,
            TotalPlayCount = totalPlayCount ,
            NewUsersToday = newUsersToday ,
            CachedTracks = activeCachedTracks ,
            Meta = new AdminDashboardSummaryMetaDto
            {
                TimeZone = timeZoneId ,
                TotalPlayCountScope = "all-time" ,
                CachedTracksScope = "active-only" ,
                GeneratedAtUtc = DateTime.UtcNow
            }
        };
    }

    public async Task<IReadOnlyList<AdminDashboardDailyMetricDto>> GetUserGrowthAsync(
    AdminDashboardFilterDto filter ,
    CancellationToken cancellationToken = default)
    {
        var groupedData = await _context.Users
            .Where(x => x.CreatedAt >= filter.RangeStartUtc && x.CreatedAt < filter.RangeEndUtc)
            .GroupBy(x => x.CreatedAt.Date)
            .Select(g => new
            {
                Date = g.Key ,
                Value = g.LongCount()
            })
            .OrderBy(x => x.Date)
            .ToListAsync(cancellationToken);

        return groupedData
            .Select(x => new AdminDashboardDailyMetricDto
            {
                Date = x.Date.ToString("yyyy-MM-dd") ,
                Value = x.Value
            })
            .ToList();
    }
    /*
    public async Task<IReadOnlyList<AdminDashboardDailyMetricDto>> GetPlayTrendAsync(
    AdminDashboardFilterDto filter ,
    CancellationToken cancellationToken = default)
    {
        var groupedData = await _context.ListeningHistories
            .Where(x => x.ListenedAt >= filter.RangeStartUtc && x.ListenedAt < filter.RangeEndUtc)
            .GroupBy(x => x.ListenedAt.Date)
            .Select(g => new
            {
                Date = g.Key ,
                Value = g.LongCount()
            })
            .OrderBy(x => x.Date)
            .ToListAsync(cancellationToken);

        return groupedData
            .Select(x => new AdminDashboardDailyMetricDto
            {
                Date = x.Date.ToString("yyyy-MM-dd") ,
                Value = x.Value
            })
            .ToList();
    }
    */

    public async Task<IReadOnlyList<AdminDashboardDailyMetricDto>> GetPlayTrendAsync(
        AdminDashboardFilterDto filter ,
        CancellationToken cancellationToken = default)
    {
        var timeZone = ResolveTimeZone(filter.TimeZoneId);

        var listenedAtUtcValues = await _context.ListeningHistories
            .AsNoTracking()
            .Where(x => x.ListenedAt >= filter.RangeStartUtc
                     && x.ListenedAt < filter.RangeEndUtc)
            .Select(x => x.ListenedAt)
            .ToListAsync(cancellationToken);

        var result = listenedAtUtcValues
            .Select(x => ConvertUtcToLocalDate(x , timeZone))
            .GroupBy(x => x)
            .Select(g => new AdminDashboardDailyMetricDto
            {
                Date = g.Key.ToString("yyyy-MM-dd") ,
                Value = g.LongCount()
            })
            .OrderBy(x => x.Date)
            .ToList();

        return result;
    }

    private static DateTime ConvertUtcToLocalDate(DateTime utcDateTime , TimeZoneInfo timeZone)
    {
        var normalizedUtc = utcDateTime.Kind == DateTimeKind.Utc
            ? utcDateTime
            : DateTime.SpecifyKind(utcDateTime , DateTimeKind.Utc);

        return TimeZoneInfo.ConvertTimeFromUtc(normalizedUtc , timeZone).Date;
    }

    private static TimeZoneInfo ResolveTimeZone(string timeZoneId)
    {
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById(timeZoneId);
        }
        catch ( TimeZoneNotFoundException )
        {
            return TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
        }
        catch ( InvalidTimeZoneException )
        {
            return TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
        }
    }


    public async Task<IReadOnlyList<AdminDashboardTopTrackItemDto>> GetTopTracksAsync(
    AdminDashboardFilterDto filter ,
    int limit ,
    CancellationToken cancellationToken = default)
    {
        var topTrackAggregates = await _context.ListeningHistories
            .Where(x => x.ListenedAt >= filter.RangeStartUtc && x.ListenedAt < filter.RangeEndUtc)
            .GroupBy(x => x.TrackExternalId)
            .Select(g => new
            {
                TrackExternalId = g.Key ,
                PlayCount = g.LongCount() ,
                TotalDurationListened = g.Sum(x => (long?) x.DurationListened) ?? 0
            })
            .OrderByDescending(x => x.PlayCount)
            .ThenBy(x => x.TrackExternalId)
            .Take(limit)
            .ToListAsync(cancellationToken);

        var trackExternalIds = topTrackAggregates
            .Select(x => x.TrackExternalId)
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Distinct()
            .ToList();

        var cachedTracks = await _context.CachedTracks
            .Where(x => trackExternalIds.Contains(x.ExternalId))
            .Select(x => new
            {
                x.ExternalId ,
                x.Title ,
                x.ArtistName ,
                x.ArtworkUrl ,
                x.DurationSeconds
            })
            .ToListAsync(cancellationToken);

        var cachedTrackDictionary = cachedTracks
            .GroupBy(x => x.ExternalId)
            .ToDictionary(
                g => g.Key ,
                g => g.First());

        var result = topTrackAggregates
            .Select(x =>
            {
                cachedTrackDictionary.TryGetValue(x.TrackExternalId , out var cachedTrack);

                return new AdminDashboardTopTrackItemDto
                {
                    TrackExternalId = x.TrackExternalId ,
                    Title = cachedTrack?.Title ,
                    ArtistName = cachedTrack?.ArtistName ,
                    ArtworkUrl = cachedTrack?.ArtworkUrl ,
                    DurationSeconds = cachedTrack?.DurationSeconds ,
                    PlayCount = x.PlayCount ,
                    TotalDurationListened = x.TotalDurationListened
                };
            })
            .ToList();

        return result;
    }
}
