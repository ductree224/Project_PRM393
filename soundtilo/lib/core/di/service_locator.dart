import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:soundtilo/core/constants/api_urls.dart';
import 'package:soundtilo/core/network/api_client.dart';

// Data Sources
import 'package:soundtilo/data/sources/auth_remote_data_source.dart';
import 'package:soundtilo/data/sources/track_remote_data_source.dart';
import 'package:soundtilo/data/sources/playlist_remote_data_source.dart';
import 'package:soundtilo/data/sources/favorite_remote_data_source.dart';
import 'package:soundtilo/data/sources/history_remote_data_source.dart';
import 'package:soundtilo/data/sources/lyrics_remote_data_source.dart';
import 'package:soundtilo/data/sources/comment_remote_data_source.dart';
import 'package:soundtilo/data/sources/admin_remote_data_source.dart';
// BỔ SUNG: Data Source cho Waitlist
import 'package:soundtilo/data/sources/waitlist_remote_data_source.dart';
import 'package:soundtilo/data/sources/artist_remote_data_source.dart';
import 'package:soundtilo/data/sources/album_remote_data_source.dart';

// Repository Implementations
import 'package:soundtilo/data/repository/auth_repository_impl.dart';
import 'package:soundtilo/data/repository/track_repository_impl.dart';
import 'package:soundtilo/data/repository/playlist_repository_impl.dart';
import 'package:soundtilo/data/repository/favorite_repository_impl.dart';
import 'package:soundtilo/data/repository/history_repository_impl.dart';
import 'package:soundtilo/data/repository/lyrics_repository_impl.dart';
import 'package:soundtilo/data/repository/comment_repository_impl.dart';
import 'package:soundtilo/data/repository/admin_repository_impl.dart';
// BỔ SUNG: Repository Impl cho Waitlist
import 'package:soundtilo/data/repository/waitlist_repository_impl.dart';
import 'package:soundtilo/data/repository/artist_repository_impl.dart';
import 'package:soundtilo/data/repository/album_repository_impl.dart';

// Domain Repositories (abstract)
import 'package:soundtilo/domain/repository/auth_repository.dart';
import 'package:soundtilo/domain/repository/track_repository.dart';
import 'package:soundtilo/domain/repository/playlist_repository.dart';
import 'package:soundtilo/domain/repository/favorite_repository.dart';
import 'package:soundtilo/domain/repository/history_repository.dart';
import 'package:soundtilo/domain/repository/lyrics_repository.dart';
import 'package:soundtilo/domain/repository/comment_repository.dart';
import 'package:soundtilo/domain/repository/admin_repository.dart';
// BỔ SUNG: Domain Repository cho Waitlist
import 'package:soundtilo/domain/repository/waitlist_repository.dart';
import 'package:soundtilo/domain/repositories/artist_repository.dart';
import 'package:soundtilo/domain/repositories/album_repository.dart';

// Use Cases
import 'package:soundtilo/domain/usecases/auth_usecases.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';
import 'package:soundtilo/domain/usecases/comment_usecases.dart';
import 'package:soundtilo/domain/usecases/playlist_usecases.dart';
import 'package:soundtilo/domain/usecases/favorite_usecases.dart';
import 'package:soundtilo/domain/usecases/admin_user_usecases.dart';
// BỔ SUNG: UseCases cho Waitlist
import 'package:soundtilo/domain/usecases/waitlist_usecases.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // ===================== External =====================
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // ===================== Plain Dio (no auth interceptor) =====================
  // Used ONLY by AuthRemoteDataSource to avoid circular dependency:
  // AuthRemoteDataSource → ApiClient → AuthRepository → AuthRemoteDataSource
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: ApiUrls.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    ),
    instanceName: 'plainDio',
  );

  // ===================== Data Sources =====================
  // Auth uses plain Dio (register/login/refresh don't need JWT)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl<Dio>(instanceName: 'plainDio')),
  );
  sl.registerLazySingleton<TrackRemoteDataSource>(
    () => TrackRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<PlaylistRemoteDataSource>(
    () => PlaylistRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<FavoriteRemoteDataSource>(
    () => FavoriteRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<HistoryRemoteDataSource>(
    () => HistoryRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<LyricsRemoteDataSource>(
    () => LyricsRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<CommentRemoteDataSource>(
    () => CommentRemoteDataSource(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSource(sl<ApiClient>().dio),
  );
  // BỔ SUNG: Đăng ký WaitlistRemoteDataSource
  sl.registerLazySingleton<WaitlistRemoteDataSource>(
    () => WaitlistRemoteDataSourceImpl(sl<ApiClient>().dio),
  );

  sl.registerLazySingleton<ArtistRemoteDataSource>(
    () => ArtistRemoteDataSourceImpl(sl<ApiClient>().dio),
  );
  sl.registerLazySingleton<AlbumRemoteDataSource>(
    () => AlbumRemoteDataSourceImpl(sl<ApiClient>().dio),
  );

  // ===================== Repositories =====================
  sl.registerLazySingleton<AuthRepository>(
    () =>
        AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<TrackRepository>(
    () => TrackRepositoryImpl(sl<TrackRemoteDataSource>()),
  );
  sl.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(sl<PlaylistRemoteDataSource>()),
  );
  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(sl<FavoriteRemoteDataSource>()),
  );
  sl.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(sl<HistoryRemoteDataSource>()),
  );
  sl.registerLazySingleton<LyricsRepository>(
    () => LyricsRepositoryImpl(sl<LyricsRemoteDataSource>()),
  );
  sl.registerLazySingleton<CommentRepository>(
    () => CommentRepositoryImpl(sl<CommentRemoteDataSource>()),
  );
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(sl<AdminRemoteDataSource>()),
  );
  // BỔ SUNG: Đăng ký WaitlistRepository
  sl.registerLazySingleton<WaitlistRepository>(
    () => WaitlistRepositoryImpl(sl<WaitlistRemoteDataSource>()),
  );
  sl.registerLazySingleton<ArtistRepository>(
    () => ArtistRepositoryImpl(sl<ArtistRemoteDataSource>()),
  );
  sl.registerLazySingleton<AlbumRepository>(
    () => AlbumRepositoryImpl(sl<AlbumRemoteDataSource>()),
  );

  // ===================== API Client (with JWT interceptor) =====================
  // Registered after AuthRepository to avoid circular dependency
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<AuthRepository>()));

  // ===================== Use Cases =====================
  // Auth
  sl.registerLazySingleton(() => SignUpUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => IsLoggedInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GoogleSignInUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl<AuthRepository>()));

  // Tracks
  sl.registerLazySingleton(() => SearchTracksUseCase(sl<TrackRepository>()));
  sl.registerLazySingleton(() => GetTrendingUseCase(sl<TrackRepository>()));
  sl.registerLazySingleton(() => GetTrackUseCase(sl<TrackRepository>()));
  sl.registerLazySingleton(() => GetStreamUrlUseCase(sl<TrackRepository>()));

  // Playlists
  sl.registerLazySingleton(() => GetPlaylistsUseCase(sl<PlaylistRepository>()));
  sl.registerLazySingleton(
    () => GetPlaylistDetailUseCase(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton(
    () => CreatePlaylistUseCase(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdatePlaylistUseCase(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton(
    () => DeletePlaylistUseCase(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton(
    () => AddTrackToPlaylistUseCase(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton(
    () => RemoveTrackFromPlaylistUseCase(sl<PlaylistRepository>()),
  );
  sl.registerLazySingleton(
    () => ReorderTracksInPlaylistUseCase(sl<PlaylistRepository>()),
  );

  // Favorites
  sl.registerLazySingleton(
    () => ToggleFavoriteUseCase(sl<FavoriteRepository>()),
  );
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl<FavoriteRepository>()));
  sl.registerLazySingleton(() => IsFavoriteUseCase(sl<FavoriteRepository>()));

  // Comments
  sl.registerLazySingleton(() => GetCommentsUseCase(sl<CommentRepository>()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl<CommentRepository>()));
  sl.registerLazySingleton(() => DeleteCommentUseCase(sl<CommentRepository>()));

  // Admin Users
  sl.registerLazySingleton(() => GetAdminUsersUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(() => BanAdminUserUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(() => UnbanAdminUserUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(
    () => ChangeAdminUserRoleUseCase(sl<AdminRepository>()),
  );
  sl.registerLazySingleton(() => DeleteAdminUserUseCase(sl<AdminRepository>()));
  sl.registerLazySingleton(
    () => GetAdminUserHistoryUseCase(sl<AdminRepository>()),
  );
  sl.registerLazySingleton(
    () => GetAdminUserFavoritesUseCase(sl<AdminRepository>()),
  );
  sl.registerLazySingleton(
    () => GetAdminUserPlaylistsUseCase(sl<AdminRepository>()),
  );

  // BỔ SUNG: Đăng ký Waitlist UseCases
  sl.registerLazySingleton(() => GetWaitlistUseCase(sl<WaitlistRepository>()));
  sl.registerLazySingleton(
    () => AddTrackToWaitlistUseCase(sl<WaitlistRepository>()),
  );
  sl.registerLazySingleton(
    () => RemoveTrackFromWaitlistUseCase(sl<WaitlistRepository>()),
  );
  sl.registerLazySingleton(
    () => ReorderWaitlistUseCase(sl<WaitlistRepository>()),
  );
  sl.registerLazySingleton(
    () => ClearWaitlistUseCase(sl<WaitlistRepository>()),
  );
}
