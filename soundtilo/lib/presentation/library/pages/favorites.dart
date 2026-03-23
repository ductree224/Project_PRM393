import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/common/widgets/track/track_tile.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/library_event.dart';
import 'package:soundtilo/presentation/library/bloc/library_state.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài hát yêu thích')),
      body: BlocBuilder<LibraryBloc, LibraryState>(
        builder: (context, state) {
          if (state is LibraryLoading || state is LibraryInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LibraryError) {
            return Center(child: Text(state.message));
          }

          if (state is LibraryLoaded || state is LibraryRefreshing) {
            final favoriteTrackIds = state is LibraryLoaded
                ? state.favoriteTrackIds
                : (state as LibraryRefreshing).favoriteTrackIds;

            if (favoriteTrackIds.isEmpty) {
              return const Center(
                child: Text('Bạn chưa có bài hát yêu thích nào.'),
              );
            }

            return _FavoriteTracksList(favoriteTrackIds: favoriteTrackIds);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _FavoriteTracksList extends StatefulWidget {
  final List<String> favoriteTrackIds;

  const _FavoriteTracksList({required this.favoriteTrackIds});

  @override
  State<_FavoriteTracksList> createState() => _FavoriteTracksListState();
}

class _FavoriteTracksListState extends State<_FavoriteTracksList> {
  late Future<List<TrackEntity>> _tracksFuture;

  @override
  void initState() {
    super.initState();
    _tracksFuture = _loadTracks(widget.favoriteTrackIds);
  }

  @override
  void didUpdateWidget(covariant _FavoriteTracksList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.favoriteTrackIds != widget.favoriteTrackIds) {
      _tracksFuture = _loadTracks(widget.favoriteTrackIds);
    }
  }

  Future<List<TrackEntity>> _loadTracks(List<String> ids) async {
    final getTrackUseCase = sl<GetTrackUseCase>();
    final futures = ids.map(getTrackUseCase.call);
    final results = await Future.wait(futures);
    return results
        .where((result) => result.isRight())
        .map(
          (result) => result.getOrElse(
            () => const TrackEntity(
              externalId: '',
              source: 'audius',
              title: '',
              artistName: '',
              durationSeconds: 0,
            ),
          ),
        )
        .where((track) => track.externalId.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TrackEntity>>(
      future: _tracksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final tracks = snapshot.data ?? const <TrackEntity>[];
        if (tracks.isEmpty) {
          return ListView.builder(
            itemCount: widget.favoriteTrackIds.length,
            itemBuilder: (context, index) {
              final trackId = widget.favoriteTrackIds[index];
              return ListTile(
                leading: const Icon(Icons.favorite, color: AppColors.primary),
                title: Text(trackId),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    context.read<LibraryBloc>().add(
                      LibraryToggleFavorite(trackId),
                    );
                  },
                ),
              );
            },
          );
        }

        return ListView.builder(
          itemCount: tracks.length,
          itemBuilder: (context, index) {
            final track = tracks[index];
            return TrackTile(
              track: track,
              onTap: () {
                Navigator.push(
                  context,
                  PlayerPage.createRoute(
                    track: track,
                    queue: tracks,
                  ),
                );
              },
              onMoreTap: () {
                context.read<LibraryBloc>().add(
                  LibraryToggleFavorite(track.externalId),
                );
              },
              trailingIcon: Icons.remove_circle_outline,
              trailingIconColor: AppColors.primary,
            );
          },
        );
      },
    );
  }
}
