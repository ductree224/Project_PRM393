import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/common/widgets/track/track_card.dart';
import 'package:soundtilo/common/widgets/track/track_tile.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:soundtilo/presentation/home/bloc/home_bloc.dart';
import 'package:soundtilo/presentation/home/bloc/home_event.dart';
import 'package:soundtilo/presentation/home/bloc/home_state.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';
import 'package:soundtilo/presentation/search/bloc/search_bloc.dart';
import 'package:soundtilo/presentation/search/pages/search.dart';

class HomePage extends StatelessWidget {
  static const int _horizontalPreviewLimit = 8;

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            if (previous.runtimeType != current.runtimeType) {
              return true;
            }

            if (previous is HomeLoaded && current is HomeLoaded) {
              return previous.trendingTracks != current.trendingTracks;
            }

            if (previous is HomeRefreshing && current is HomeRefreshing) {
              return previous.trendingTracks != current.trendingTracks;
            }

            return false;
          },
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, size: 64, color: AppColors.grey),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<HomeBloc>().add(HomeLoadTrending()),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              );
            }

            if (state is HomeLoaded) {
              return _buildContent(
                context,
                state.trendingTracks,
                hasMore: state.hasMore,
                isLoadingMore: state.isLoadingMore,
              );
            }

            if (state is HomeRefreshing) {
              return Stack(
                children: [
                  _buildContent(
                    context,
                    state.trendingTracks,
                    hasMore: state.hasMore,
                    isLoadingMore: false,
                  ),
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<TrackEntity> tracks, {
    bool hasMore = true,
    bool isLoadingMore = false,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification &&
            hasMore &&
            !isLoadingMore &&
            notification.metrics.pixels >
                notification.metrics.maxScrollExtent - 400) {
          context.read<HomeBloc>().add(HomeLoadMore());
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeBloc>().add(HomeRefresh());
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  final searchBloc = context.read<SearchBloc>();
                  final libraryBloc = context.read<LibraryBloc>();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MultiBlocProvider(
                        providers: [
                          BlocProvider.value(value: searchBloc),
                          BlocProvider.value(value: libraryBloc),
                        ],
                        child: const SearchPage(),
                      ),
                    ),
                  );
                },
              ),
              title: SvgPicture.asset(AppVectors.logo, height: 35),
              centerTitle: true,
              actions: [
                // Nút chuyển đổi Mode (Light/Dark)
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, mode) {
                    final isDark = mode == ThemeMode.dark || 
                                  (mode == ThemeMode.system && context.isDarkMode);
                    return IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? Colors.orangeAccent : Colors.indigo,
                      ),
                      onPressed: () {
                        context.read<ThemeCubit>().updateTheme(
                          isDark ? ThemeMode.light : ThemeMode.dark
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Section: Thịnh hành (horizontal scroll)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Thịnh hành',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: tracks.length > _horizontalPreviewLimit
                      ? _horizontalPreviewLimit
                      : tracks.length,
                  itemBuilder: (context, index) {
                    return TrackCard(
                      track: tracks[index],
                      onTap: () => _openPlayer(context, tracks[index], tracks),
                    );
                  },
                ),
              ),
            ),

            // Section: Danh sách bài hát
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Dành cho bạn',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: context.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final track = tracks[index];
                return TrackTile(
                  key: ValueKey(track.externalId),
                  track: track,
                  onTap: () => _openPlayer(context, track, tracks),
                );
              }, childCount: tracks.length),
            ),

            // Loading indicator for infinite scroll
            if (isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _buildShimmerLoading(context),
                ),
              )
            else if (!hasMore && tracks.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Đã hiển thị tất cả bài hát',
                      style: TextStyle(color: AppColors.grey, fontSize: 13),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final baseColor = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.withValues(alpha: 0.15);
    final highlightColor = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.grey.withValues(alpha: 0.05);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(3, (_) {
          return ListTile(
            leading: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            title: Container(
              height: 14,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Container(
              height: 10,
              width: 80,
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _openPlayer(
    BuildContext context,
    TrackEntity track,
    List<TrackEntity> queue,
  ) {
    Navigator.push(
      context,
      PlayerPage.createRoute(
        track: track,
        queue: queue,
      ),
    );
  }
}
