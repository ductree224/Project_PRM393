class AdminDashboardSummaryEntity {
  final int totalUsers;
  final int totalPlayCount;
  final int newUsersToday;
  final int cachedTracks;

  const AdminDashboardSummaryEntity({
    required this.totalUsers,
    required this.totalPlayCount,
    required this.newUsersToday,
    required this.cachedTracks,
  });
}

class AdminDashboardDailyPointEntity {
  final String date;
  final int value;

  const AdminDashboardDailyPointEntity({
    required this.date,
    required this.value,
  });
}

class AdminDashboardTopTrackEntity {
  final String trackExternalId;
  final String? title;
  final String? artistName;
  final String? artworkUrl;
  final int playCount;

  const AdminDashboardTopTrackEntity({
    required this.trackExternalId,
    this.title,
    this.artistName,
    this.artworkUrl,
    required this.playCount,
  });
}

class AdminDashboardChartEntity {
  final String? month;
  final List<AdminDashboardDailyPointEntity> points;

  const AdminDashboardChartEntity({this.month, required this.points});
}

class AdminDashboardTopTracksEntity {
  final String? month;
  final List<AdminDashboardTopTrackEntity> items;

  const AdminDashboardTopTracksEntity({this.month, required this.items});
}
