import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/common/widgets/track/track_tile.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/data/models/album_model.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
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
  static const int _verticalListLimit = 12;

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
              return _buildContent(context, state.trendingTracks, state.adminAlbums);
            }

            if (state is HomeRefreshing) {
              return Stack(
                children: [
                  _buildContent(context, state.trendingTracks, state.adminAlbums),
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

  Widget _buildContent(BuildContext context, List<TrackEntity> tracks, List<AlbumModel> adminAlbums) {
    // 1. Group trending tracks into primitive albums
    final Map<String, List<TrackEntity>> albumGroups = {};
    for (final track in tracks) {
      final key = '${track.albumName ?? track.title}_${track.artistName}'.toLowerCase();
      albumGroups.putIfAbsent(key, () => []).add(track);
    }

    // 2. Identify and apply admin overrides
    final List<LocalAlbum> finalAlbums = [];
    final Set<String> matchedKeys = {};

    for (final adminAlbum in adminAlbums) {
      final key = '${adminAlbum.title}_${adminAlbum.artist?.name ?? ""}'.toLowerCase();
      final tracksForAdmin = albumGroups[key] ?? [];
      
      finalAlbums.add(LocalAlbum(
        title: adminAlbum.title,
        artistName: adminAlbum.artist?.name ?? 'Unknown',
        coverImageUrl: adminAlbum.coverImageUrl ?? '',
        tracks: tracksForAdmin,
      ));
      
      if (tracksForAdmin.isNotEmpty) {
        matchedKeys.add(key);
      }
    }

    // 3. Add remaining trending albums that weren't overridden
    albumGroups.forEach((key, albumTracks) {
      if (!matchedKeys.contains(key)) {
        final firstTrack = albumTracks.first;
        finalAlbums.add(LocalAlbum(
          title: firstTrack.albumName ?? firstTrack.title,
          artistName: firstTrack.artistName,
          coverImageUrl: firstTrack.artworkUrl ?? '',
          tracks: albumTracks,
        ));
      }
    });

    final displayedAlbums = finalAlbums.length > _horizontalPreviewLimit
        ? finalAlbums.take(_horizontalPreviewLimit).toList()
        : finalAlbums;

    final visibleTracks = tracks.length > _verticalListLimit
        ? tracks.take(_verticalListLimit).toList(growable: false)
        : tracks;

    return RefreshIndicator(
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
            title: SvgPicture.asset(AppVectors.logo, height: 40),
            centerTitle: true,
            actions: [
              IconButton(
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
            ],
          ),

          // Section: Thịnh hành (horizontal scroll)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Album Thịnh hành',
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
              final track = visibleTracks[index];
              return TrackTile(
                track: track,
                onTap: () => _openPlayer(context, track, tracks),
              );
            }, childCount: visibleTracks.length),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  void _openPlayer(
    BuildContext context,
    TrackEntity track,
    List<TrackEntity> queue,
  ) {
    final libraryBloc = context.read<LibraryBloc>();
    Navigator.push(
      context,
      PlayerPage.createRoute(
        track: track,
        queue: queue,
        libraryBloc: libraryBloc,
      ),
    );
  }
}
