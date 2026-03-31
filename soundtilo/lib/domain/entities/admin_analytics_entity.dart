class AdminAnalyticsOverviewEntity {
  final int totalUsers;
  final int totalBannedUsers;
  final int totalAdmins;
  final int newUsersLast7Days;
  final int totalListeningTimeSeconds;
  final int totalTracks;
  final int totalPlaylists;

  const AdminAnalyticsOverviewEntity({
    required this.totalUsers,
    required this.totalBannedUsers,
    required this.totalAdmins,
    required this.newUsersLast7Days,
    required this.totalListeningTimeSeconds,
    required this.totalTracks,
    required this.totalPlaylists,
  });
}

class AdminAnalyticsTopTrackEntity {
  final String trackId;
  final String title;
  final String artist;
  final int playCount;

  const AdminAnalyticsTopTrackEntity({
    required this.trackId,
    required this.title,
    required this.artist,
    required this.playCount,
  });
}

class AdminAnalyticsDailyStatEntity {
  final String date;
  final int newUsers;
  final int totalListens;
  final int totalListeningTimeSeconds;

  const AdminAnalyticsDailyStatEntity({
    required this.date,
    required this.newUsers,
    required this.totalListens,
    required this.totalListeningTimeSeconds,
  });
}

class AdminSubscriptionStatsEntity {
  final int totalPremiumUsers;
  final int totalFreeUsers;
  final int activeSubscriptions;
  final double totalRevenue;

  const AdminSubscriptionStatsEntity({
    required this.totalPremiumUsers,
    required this.totalFreeUsers,
    required this.activeSubscriptions,
    required this.totalRevenue,
  });
}
