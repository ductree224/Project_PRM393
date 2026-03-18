import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/debug/perf_trace.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/usecases/favorite_usecases.dart';
import 'package:soundtilo/domain/usecases/playlist_usecases.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';
import 'package:soundtilo/presentation/home/bloc/home_bloc.dart';
import 'package:soundtilo/presentation/home/bloc/home_event.dart';
import 'package:soundtilo/presentation/home/pages/home.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/library_event.dart';
import 'package:soundtilo/presentation/library/pages/library.dart';
import 'package:soundtilo/presentation/profile/pages/profile.dart';
import 'package:soundtilo/presentation/search/bloc/search_bloc.dart';
import 'package:soundtilo/presentation/search/pages/search.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  bool _homeLoadRequested = false;
  bool _libraryLoadRequested = false;
  late final HomeBloc _homeBloc;
  late final SearchBloc _searchBloc;
  late final LibraryBloc _libraryBloc;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = <Widget>[
      const HomePage(),
      SearchPage(onBackPressed: _onSearchTabBack),
      const LibraryPage(),
      const ProfilePage(),
    ];

    _homeBloc = HomeBloc(
      getTrendingUseCase: sl<GetTrendingUseCase>(),
    );

    _searchBloc = SearchBloc(
      searchTracksUseCase: sl<SearchTracksUseCase>(),
    );

    _libraryBloc = LibraryBloc(
      getPlaylistsUseCase: sl<GetPlaylistsUseCase>(),
      createPlaylistUseCase: sl<CreatePlaylistUseCase>(),
      updatePlaylistUseCase: sl<UpdatePlaylistUseCase>(),
      deletePlaylistUseCase: sl<DeletePlaylistUseCase>(),
      addTrackToPlaylistUseCase: sl<AddTrackToPlaylistUseCase>(),
      removeTrackFromPlaylistUseCase: sl<RemoveTrackFromPlaylistUseCase>(),
      toggleFavoriteUseCase: sl<ToggleFavoriteUseCase>(),
      getFavoritesUseCase: sl<GetFavoritesUseCase>(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureTabDataLoaded(_currentIndex.value);
    });

    PerfTrace.log('shell.blocLifecycle', 'initialized shell blocs once');
  }

  void _onSearchTabBack() {
    if (_currentIndex.value == 1) {
      _currentIndex.value = 0;
      _ensureTabDataLoaded(0);
    }
  }

  void _ensureTabDataLoaded(int tabIndex) {
    if (tabIndex == 0 && !_homeLoadRequested) {
      _homeLoadRequested = true;
      _homeBloc.add(HomeLoadTrending());
    }
    if (tabIndex == 2 && !_libraryLoadRequested) {
      _libraryLoadRequested = true;
      _libraryBloc.add(LibraryLoad());
    }
  }

  @override
  void dispose() {
    _homeBloc.close();
    _searchBloc.close();
    _libraryBloc.close();
    _currentIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _searchBloc),
        BlocProvider.value(value: _libraryBloc),
      ],
      child: Scaffold(
        body: ValueListenableBuilder<int>(
          valueListenable: _currentIndex,
          builder: (context, index, _) => IndexedStack(
            index: index,
            children: _pages,
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _currentIndex,
          builder: (context, index, _) => BottomNavigationBar(
            currentIndex: index,
            onTap: (nextIndex) {
              if (_currentIndex.value == nextIndex) {
                return;
              }

              final tabSwitchStopwatch = Stopwatch()..start();
              _currentIndex.value = nextIndex;
              _ensureTabDataLoaded(nextIndex);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                tabSwitchStopwatch.stop();
                PerfTrace.slow(
                  'shell.tabSwitch',
                  tabSwitchStopwatch,
                  thresholdMs: 48,
                  values: <String, Object?>{
                    'from': index,
                    'to': nextIndex,
                  },
                );
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.grey,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 11,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Trang chủ',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                activeIcon: Icon(Icons.search),
                label: 'Tìm kiếm',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_music_outlined),
                activeIcon: Icon(Icons.library_music),
                label: 'Thư viện',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
