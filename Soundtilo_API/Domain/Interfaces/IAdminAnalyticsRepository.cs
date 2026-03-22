namespace Domain.Interfaces;

public interface IAdminAnalyticsRepository
{
    Task<int> CountUsersByRoleAsync(string role);
    Task<int> CountBannedUsersAsync();
    Task<int> CountNewUsersSinceAsync(DateTime since);
    Task<long> SumListeningTimeSecondsAsync();
    Task<int> CountCachedTracksAsync();
    Task<int> CountPlaylistsAsync();

    Task<IEnumerable<(string TrackExternalId, string Title, string Artist, int PlayCount)>> GetTopTracksAsync(int count);

    Task<IEnumerable<(DateOnly Date, int NewUsers, int TotalListens, long TotalListeningSeconds)>> GetDailyStatsAsync(
        DateOnly from,
        DateOnly to);
}
