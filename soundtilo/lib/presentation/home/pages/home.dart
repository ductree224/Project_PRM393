import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/common/widgets/track/track_tile.dart';
import 'package:soundtilo/common/widgets/track/track_card.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/data/models/album_model.dart';
import 'package:soundtilo/data/models/track_model.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:soundtilo/presentation/home/bloc/home_bloc.dart';
import 'package:soundtilo/presentation/home/bloc/home_event.dart';
import 'package:soundtilo/presentation/home/bloc/home_state.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';
import 'package:soundtilo/presentation/home/models/local_album.dart';
import 'package:soundtilo/presentation/home/widgets/album_card.dart';
import 'package:soundtilo/presentation/home/pages/album_detail.dart';
import 'package:soundtilo/presentation/search/bloc/search_bloc.dart';
import 'package:soundtilo/presentation/search/pages/search.dart';

class HomePage extends StatelessWidget {
  static const int _horizontalPreviewLimit = 8;
  final List<String> _tags = const [
    'pop',
    'rock',
    'hip-hop',
    'electronic',
    'jazz',
    'classical',
    'lofi',
    'r&b',
  ];

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is HomeError) {
              return _buildErrorState(context, state.message);
            }

            if (state is HomeLoaded) {
              return _buildContent(context, state);
            }

            if (state is HomeRefreshing) {
              return Stack(
                children: [
                  _buildContentFromState(context, state.trendingTracks, state.adminAlbums, state.currentOffset, state.hasMore),
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

  Widget _buildContent(BuildContext context, HomeLoaded state) {
    return _buildContentFromState(
      context, 
      state.trendingTracks, 
      state.adminAlbums, 
      state.currentOffset, 
      state.hasMore,
      selectedTag: state.selectedTag,
      tagTracks: state.tagTracks,
      isTagLoading: state.isTagLoading,
    );
  }

  Widget _buildContentFromState(
    BuildContext context, 
    List<TrackEntity> trendingTracks, 
    List<AlbumModel> adminAlbums,
    int currentOffset,
    bool hasMore,
    {
      String selectedTag = 'pop',
      List<TrackEntity> tagTracks = const [],
      bool isTagLoading = false,
    }
  ) {
    // Show only admin-managed albums
    final List<LocalAlbum> displayedAlbums = adminAlbums.map((adminAlbum) {
      return LocalAlbum(
        id: adminAlbum.id,
        title: adminAlbum.title,
        artistName: adminAlbum.artist?.name ?? 'Unknown',
        coverImageUrl: adminAlbum.coverImageUrl ?? '',
        // These are just placeholders/previews; tracks will be fetched in detail page
        tracks: adminAlbum.tracks.map((at) => at.track ?? TrackModel(
          externalId: at.trackExternalId,
          source: 'audius',
          title: 'Loading...',
          artistName: adminAlbum.artist?.name ?? 'Unknown',
          durationSeconds: 0,
        )).toList(),
      );
    }).toList();

    return RefreshIndicator(
      onRefresh: () async => context.read<HomeBloc>().add(HomeRefresh()),
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200 &&
              state.hasMore &&
              !state.isLoadingMore) {
            context.read<HomeBloc>().add(HomeLoadMore());
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),

            _buildSectionHeader(context, 'Thịnh hành'),
            _buildTrendingList(state.trendingTracks),

          _buildSectionHeader(context, 'Khám phá theo thể loại'),
          _buildTagBar(context, selectedTag),
          _buildTagTracks(context, tagTracks, isTagLoading),

          if (displayedAlbums.isNotEmpty) ...[
            _buildSectionHeader(context, 'Album Thịnh hành'),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: displayedAlbums.length,
                  itemBuilder: (context, index) {
                    final album = displayedAlbums[index];
                    return AlbumCard(
                      album: album,
                      onTap: () {
                        final libraryBloc = context.read<LibraryBloc>();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: libraryBloc,
                              child: AlbumDetailPage(album: album),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],

          _buildSectionHeader(context, 'Dành cho bạn'),
          _buildInfiniteList(context, trendingTracks, hasMore),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: SvgPicture.asset(
          AppVectors.logo,
          height: 30,
          alignment: Alignment.centerLeft,
        ),
      ),
      title: GestureDetector(
        onTap: () => _openSearch(context),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: context.isDarkMode ? Colors.white10 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 18, color: AppColors.grey),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Tìm kiếm bài hát...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
      centerTitle: true,
      actions: [_buildThemeSwitcher(), const SizedBox(width: 4)],
    );
  }

  Widget _buildTagBar(BuildContext context, String selectedTag) {
    return SliverToBoxAdapter(
      child: Container(
        height: 45,
        margin: const EdgeInsets.only(bottom: 15),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _tags.length,
          itemBuilder: (context, index) {
            final tag = _tags[index];
            final isSelected = tag == selectedTag;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => context.read<HomeBloc>().add(HomeLoadByTag(tag)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [AppColors.primary, AppColors.thirdly],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (context.isDarkMode
                              ? Colors.white10
                              : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      tag.toUpperCase(),
                      style: GoogleFonts.inter(
                        color: isSelected
                            ? Colors.white
                            : (context.isDarkMode
                                  ? Colors.grey
                                  : Colors.black87),
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTagTracks(BuildContext context, List<TrackEntity> tagTracks, bool isTagLoading) {
    if (isTagLoading) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 240,
          child: _buildHorizontalShimmerGrid(context),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Container(
        height: 240,
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(),
        child: Stack(
          children: [
            Positioned(
              left: -50,
              top: 0,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withOpacity(
                        context.isDarkMode ? 0.2 : 0.1,
                      ),
                      AppColors.primary.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -30,
              bottom: -20,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.thirdly.withOpacity(
                        context.isDarkMode ? 0.2 : 0.1,
                      ),
                      AppColors.thirdly.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
            GridView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisExtent: 280,
                mainAxisSpacing: 15,
                crossAxisSpacing: 10,
              ),
              itemCount: tagTracks.length,
              itemBuilder: (context, index) {
                final track = tagTracks[index];
                return _buildHorizontalTrackItem(context, track, tagTracks);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalTrackItem(
    BuildContext context,
    TrackEntity track,
    List<TrackEntity> queue,
  ) {
    return GestureDetector(
      onTap: () => _openPlayer(context, track, queue),
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: track.artworkUrl ?? '',
                width: 55,
                height: 55,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 55,
                  height: 55,
                  color: AppColors.grey.withOpacity(0.1),
                  child: const Icon(Icons.music_note, color: AppColors.grey),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: context.isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingList(List<TrackEntity> tracks) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 230, // Tăng từ 220 lên 230 để tránh tràn bottom 1px
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: tracks.length > _horizontalPreviewLimit
              ? _horizontalPreviewLimit
              : tracks.length,
          itemBuilder: (context, index) => TrackCard(
            track: tracks[index],
            onTap: () => _openPlayer(context, tracks[index], tracks),
          ),
        ),
      ),
    );
  }

  Widget _buildInfiniteList(BuildContext context, List<TrackEntity> tracks, bool hasMore) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= tracks.length) {
            return hasMore ? _buildShimmerLoading(context) : const SizedBox.shrink();
          }
          final track = tracks[index];
          return TrackTile(
            key: ValueKey(track.externalId),
            track: track,
            onTap: () => _openPlayer(context, track, tracks),
          );
        },
        childCount: tracks.length + (hasMore ? 1 : 0),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSwitcher() {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final isDark =
            mode == ThemeMode.dark ||
            (mode == ThemeMode.system && context.isDarkMode);
        return IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? Colors.orangeAccent : Colors.indigo,
            size: 20,
          ),
          onPressed: () => context.read<ThemeCubit>().updateTheme(
            isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        );
      },
    );
  }

  void _openSearch(BuildContext context) {
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
  }

  void _openPlayer(
    BuildContext context,
    TrackEntity track,
    List<TrackEntity> queue,
  ) {
    Navigator.push(context, PlayerPage.createRoute(track: track, queue: queue));
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off, size: 64, color: AppColors.grey),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<HomeBloc>().add(HomeLoadTrending()),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalShimmerGrid(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ? Colors.white10 : Colors.grey.shade200,
      highlightColor: context.isDarkMode
          ? Colors.white24
          : Colors.grey.shade100,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 280,
          mainAxisSpacing: 15,
          crossAxisSpacing: 10,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 150, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 10, width: 80, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.isDarkMode ? Colors.white10 : Colors.grey.shade200,
      highlightColor: context.isDarkMode
          ? Colors.white24
          : Colors.grey.shade100,
      child: ListTile(
        leading: Container(width: 56, height: 56, color: Colors.white),
        title: Container(height: 14, width: 100, color: Colors.white),
      ),
    );
  }
}
