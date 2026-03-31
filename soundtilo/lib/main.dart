import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundtilo/core/configs/theme/app_theme.dart';
import 'package:soundtilo/core/debug/perf_trace.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/core/navigation/app_navigator.dart';
import 'package:soundtilo/domain/repository/track_repository.dart';
import 'package:soundtilo/domain/usecases/auth_usecases.dart';
import 'package:soundtilo/domain/usecases/favorite_usecases.dart';
import 'package:soundtilo/domain/usecases/playlist_usecases.dart';
// BỔ SUNG: Import TrackEntity cho biến nhớ tạm
import 'package:soundtilo/domain/entities/track_entity.dart';
// BỔ SUNG: Import các UseCase và Bloc của Waitlist
import 'package:soundtilo/domain/usecases/waitlist_usecases.dart';
import 'package:soundtilo/domain/usecases/user_usecases.dart';
import 'package:soundtilo/domain/usecases/history_usecases.dart';
import 'package:soundtilo/presentation/library/bloc/waitlist/waitlist_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/waitlist/waitlist_event.dart';

import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_event.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';
import 'package:soundtilo/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:soundtilo/presentation/player/bloc/player_bloc.dart';
import 'package:soundtilo/presentation/player/bloc/player_event.dart';
import 'package:soundtilo/presentation/player/bloc/player_state.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/library_event.dart';
import 'package:soundtilo/presentation/notifications/bloc/notification_cubit.dart';
import 'package:soundtilo/presentation/notifications/bloc/notification_state.dart';
import 'package:soundtilo/presentation/notifications/notification_view_tracker.dart';
import 'package:soundtilo/presentation/player/widgets/mini_player.dart';
import 'package:soundtilo/presentation/intro/pages/get_started.dart';
import 'package:soundtilo/presentation/splash/pages/splash.dart';
import 'package:soundtilo/common/widgets/inactivity_tracker.dart';

final ValueNotifier<bool> _isPlayerRouteActive = ValueNotifier<bool>(false);

class _MiniPlayerVisibilityObserver extends NavigatorObserver {
  void _sync(Route<dynamic>? route) {
    _isPlayerRouteActive.value = route?.settings.name == PlayerPage.routeName;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _sync(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _sync(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _sync(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _sync(previousRoute);
  }
}

final _miniPlayerVisibilityObserver = _MiniPlayerVisibilityObserver();

// KHAI BÁO BIẾN GHI NHỚ BÀI HÁT CŨ CHO WAITLIST Ở ĐÂY
TrackEntity? _lastTrackForWaitlist;

Future<void> main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.toString().contains(
      '_pressedKeys[event.physicalKey] == event.logicalKey',
    )) {
      return;
    }
    FlutterError.presentError(details);
  };
  WidgetsFlutterBinding.ensureInitialized();
  PerfTrace.initFrameTimingTrace();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    if (kDebugMode) {
      print("Warning: .env file not found");
    }
  }
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );

  // Initialize DI
  await initServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create: (_) => AuthBloc(
            signUpUseCase: sl<SignUpUseCase>(),
            signInUseCase: sl<SignInUseCase>(),
            isLoggedInUseCase: sl<IsLoggedInUseCase>(),
            logoutUseCase: sl<LogoutUseCase>(),
            googleSignInUseCase: sl<GoogleSignInUseCase>(),
            forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
            resetPasswordUseCase: sl<ResetPasswordUseCase>(),
            getProfileUseCase: sl<GetProfileUseCase>(),
            updateProfileUseCase: sl<UpdateProfileUseCase>(),
            changePasswordUseCase: sl<ChangePasswordUseCase>(),
            prefs: sl<SharedPreferences>(),
          )..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (_) => PlayerBloc(
            audioPlayer: AudioPlayer(),
            trackRepository: sl<TrackRepository>(),
            toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
            isFavoriteUseCase: sl<IsFavoriteUseCase>(),
            recordListenUseCase: sl<RecordListenUseCase>(),
          ),
        ),
        BlocProvider(
          create: (_) => LibraryBloc(
            getPlaylistsUseCase: sl<GetPlaylistsUseCase>(),
            createPlaylistUseCase: sl<CreatePlaylistUseCase>(),
            updatePlaylistUseCase: sl<UpdatePlaylistUseCase>(),
            deletePlaylistUseCase: sl<DeletePlaylistUseCase>(),
            addTrackToPlaylistUseCase: sl<AddTrackToPlaylistUseCase>(),
            removeTrackFromPlaylistUseCase:
                sl<RemoveTrackFromPlaylistUseCase>(),
            toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
            getFavoritesUseCase: sl<GetFavoritesUseCase>(),
          ),
        ),
        // BỔ SUNG: Tiêm WaitlistBloc vào hệ thống
        BlocProvider(
          create: (_) => WaitlistBloc(
            getWaitlistUseCase: sl<GetWaitlistUseCase>(),
            addTrackToWaitlistUseCase: sl<AddTrackToWaitlistUseCase>(),
            removeTrackFromWaitlistUseCase:
                sl<RemoveTrackFromWaitlistUseCase>(),
            reorderWaitlistUseCase: sl<ReorderWaitlistUseCase>(),
          ),
        ),
        BlocProvider(create: (_) => NotificationCubit(sl(), sl())),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              final notifications = context.read<NotificationCubit>();
              if (state is AuthAuthenticated) {
                notifications.onAuthenticated();
              }
              if (state is AuthUnauthenticated) {
                notifications.onUnauthenticated();
                context.read<PlayerBloc>().add(PlayerStop());
                AppNavigator.key.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const GetStartedPage(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
          BlocListener<PlayerBloc, PlayerState>(
            listenWhen: (prev, curr) =>
                prev.isFavorite != curr.isFavorite && curr.currentTrack != null,
            listener: (context, state) {
              context.read<LibraryBloc>().add(
                LibraryFavoriteSync(
                  trackExternalId: state.currentTrack!.externalId,
                  isFavorite: state.isFavorite,
                ),
              );
            },
          ),
          // BỔ SUNG LISTENER MỚI CỦA WAITLIST:
          BlocListener<PlayerBloc, PlayerState>(
            listener: (context, state) {
              // 1. Kiểm tra nếu có bài cũ và bài mới khác bài cũ -> Bài cũ đã nghe xong!
              if (_lastTrackForWaitlist != null &&
                  state.currentTrack != null &&
                  _lastTrackForWaitlist!.externalId !=
                      state.currentTrack!.externalId) {
                // Báo cho Waitlist làm mờ bài CŨ đi
                context.read<WaitlistBloc>().add(
                  WaitlistMarkTrackAsPlayed(_lastTrackForWaitlist!.externalId),
                );
              }

              // 2. Cập nhật lại bộ nhớ bài hát hiện tại
              if (state.currentTrack != null) {
                _lastTrackForWaitlist = state.currentTrack;
              }
            },
          ),
          BlocListener<NotificationCubit, NotificationState>(
            listenWhen: (previous, current) =>
                previous.realtimeArrivalVersion !=
                current.realtimeArrivalVersion,
            listener: (context, state) {
              final latest = state.latestRealtimeNotification;
              if (latest == null) {
                return;
              }

              if (NotificationViewTracker.isNotificationViewOpen.value) {
                return;
              }

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text('${latest.title}: ${latest.message}'),
                    duration: const Duration(seconds: 3),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            },
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) => MaterialApp(
            navigatorKey: AppNavigator.key,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            debugShowCheckedModeBanner: false,
            navigatorObservers: [_miniPlayerVisibilityObserver],
            builder: (context, child) {
              final content = child ?? const SizedBox.shrink();
              final bottomInset =
                  MediaQuery.viewPaddingOf(context).bottom +
                  kBottomNavigationBarHeight +
                  8;

              return InactivityTracker(
                timeout: const Duration(seconds: 10),
                onTimeout: () {
                  final playerBloc = context.read<PlayerBloc>();
                  if (playerBloc.state.status == PlayerStatus.playing) {
                    playerBloc.add(PlayerPause());
                  }
                },
                child: Stack(
                  children: [
                    Positioned.fill(child: content),
                    Positioned(
                      left: 8,
                      right: 8,
                      bottom: bottomInset,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isPlayerRouteActive,
                        builder: (context, isPlayerRouteActive, _) {
                          if (isPlayerRouteActive) {
                            return const SizedBox.shrink();
                          }
                          return const MiniPlayer();
                        },
                      ),
                    ),
                    Positioned(
                      right: 16,
                      bottom: bottomInset,
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isPlayerRouteActive,
                        builder: (context, isPlayerRouteActive, _) {
                          if (isPlayerRouteActive) {
                            return const SizedBox.shrink();
                          }
                          return const MiniPlayerShowButton();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
            home: const SplashPage(),
          ),
        ),
      ),
    );
  }
}
