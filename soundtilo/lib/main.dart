import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundtilo/core/configs/theme/app_theme.dart';
import 'package:soundtilo/core/debug/perf_trace.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/core/navigation/app_navigator.dart';
import 'package:soundtilo/domain/repository/history_repository.dart';
import 'package:soundtilo/domain/repository/track_repository.dart';
import 'package:soundtilo/domain/usecases/auth_usecases.dart';
import 'package:soundtilo/domain/usecases/favorite_usecases.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_event.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';
import 'package:soundtilo/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:soundtilo/presentation/player/bloc/player_bloc.dart';
import 'package:soundtilo/presentation/player/bloc/player_event.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';
import 'package:soundtilo/presentation/player/widgets/mini_player.dart';
import 'package:soundtilo/presentation/intro/pages/get_started.dart';
import 'package:soundtilo/presentation/splash/pages/splash.dart';

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
  await dotenv.load(fileName: '.env');
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
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
            prefs: sl<SharedPreferences>(),
          )..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (_) => PlayerBloc(
            audioPlayer: AudioPlayer(),
            trackRepository: sl<TrackRepository>(),
            toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
            isFavoriteUseCase: sl<IsFavoriteUseCase>(),
            historyRepository: sl<HistoryRepository>(),
          ),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated) {
                context.read<PlayerBloc>().add(PlayerStop());
                AppNavigator.key.currentState?.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const GetStartedPage()),
                  (route) => false,
                );
              }
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

              return Stack(
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
                ],
              );
            },
            home: const SplashPage(),
          ),
        ),
      ),
    );
  }
}
