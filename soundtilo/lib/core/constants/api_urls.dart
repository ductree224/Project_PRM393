import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

class ApiUrls {
  static String get baseUrl {
    // Ưu tiên giá trị từ file .env nếu có
    if (dotenv.env['API_BASE_URL'] != null) {
      return dotenv.env['API_BASE_URL']!;
    }

    // Tự động nhận diện dựa trên nền tảng
    if (kIsWeb) {
      return 'http://localhost:5196';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:5196'; // Emulator Android
    } else if (Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux) {
      return 'http://localhost:5196';
    }

    return 'http://localhost:5196';
  }

  // Auth
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String refreshToken = '/api/auth/refresh';
  static const String googleLogin = '/api/auth/google-login';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  // Tracks
  static const String searchTracks = '/api/tracks/search';
  static const String trendingTracks = '/api/tracks/trending';
  static String getTrack(String id) => '/api/tracks/$id';
  static String getStreamUrl(String id) => '/api/tracks/$id/stream';

  // Tags (Jamendo genre browsing)
  static String tracksByTag(String tag) => '/api/tracks/tags/$tag';

  // Playlists
  static const String playlists = '/api/playlists';
  static String playlistById(String id) => '/api/playlists/$id';
  static String playlistAddTrack(String id) => '/api/playlists/$id/tracks';
  static String playlistRemoveTrack(String id, String trackId) =>
      '/api/playlists/$id/tracks/$trackId';

  // Favorites
  static const String favorites = '/api/favorites';
  static String toggleFavorite(String trackId) => '/api/favorites/$trackId';
  static String isFavorite(String trackId) => '/api/favorites/$trackId/check';

  // History
  static const String history = '/api/history';

  // Lyrics
  static const String lyrics = '/api/lyrics';

  // Users
  static const String userProfile = '/api/users/profile';
  static const String changePassword = '/api/users/change-password';

  // Subscriptions (public — no auth required)
  static const String subscriptionPlans = '/api/subscriptions/plans';

  // Admin - Users
  static const String adminUsers = '/api/admin/users';
  static String adminUserById(String userId) => '/api/admin/users/$userId';
  static String adminBanUser(String userId) => '/api/admin/users/$userId/ban';
  static String adminUnbanUser(String userId) =>
      '/api/admin/users/$userId/unban';
  static String adminChangeUserRole(String userId) =>
      '/api/admin/users/$userId/role';
  static String adminGrantPremium(String userId) =>
      '/api/admin/users/$userId/premium';
  static String adminRevokePremium(String userId) =>
      '/api/admin/users/$userId/premium';
  static String adminUserHistory(String userId) =>
      '/api/admin/users/$userId/history';
  static String adminUserFavorites(String userId) =>
      '/api/admin/users/$userId/favorites';
  static String adminUserPlaylists(String userId) =>
      '/api/admin/users/$userId/playlists';

  // Admin - Subscriptions
  static const String adminSubscriptions = '/api/admin/subscriptions';
  static const String adminSubscriptionStats = '/api/admin/subscriptions/stats';
  static const String adminSubscriptionTransactions =
      '/api/admin/subscriptions/transactions';

  // Artists
  static const String artists = '/api/artists';

  // Albums
  static const String albums = '/api/albums';

  // Admin Tracks
  static const String adminTracks = '/api/admin/tracks';
  static const String updateAdminTrackStatus = '/api/admin/tracks/status';
  static const String addTracksToAlbumToAdmin =
      '/api/admin/tracks/add-to-album';

  // Notifications
  static const String notificationsInbox = '/api/notifications/inbox';
  static const String notificationsUnreadCount =
      '/api/notifications/unread-count';
  static String notificationMarkRead(String id) =>
      '/api/notifications/$id/read';
  static const String notificationsMarkAllRead = '/api/notifications/read-all';
  static const String adminNotificationTemplates =
      '/api/notifications/admin/templates';
  static String adminNotificationTemplateById(String id) =>
      '/api/notifications/admin/templates/$id';
  static const String adminNotificationSchedules =
      '/api/notifications/admin/schedules';
  static String adminNotificationScheduleById(String id) =>
      '/api/notifications/admin/schedules/$id';
  static const String adminNotificationSendBroadcast =
      '/api/notifications/admin/send/broadcast';
  static String adminNotificationSendUser(String userId) =>
      '/api/notifications/admin/send/user/$userId';
}
