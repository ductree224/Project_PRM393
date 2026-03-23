import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/playlist_entity.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/library_event.dart';
import 'package:soundtilo/presentation/library/bloc/library_state.dart';
import 'package:soundtilo/presentation/lyrics/pages/lyrics_sheet.dart';
import 'package:soundtilo/presentation/player/bloc/player_bloc.dart';
import 'package:soundtilo/presentation/player/bloc/player_event.dart';
import 'package:soundtilo/presentation/player/bloc/player_state.dart';
import 'package:soundtilo/presentation/player/widgets/comment_sheet.dart';

class PlayerPage extends StatefulWidget {
  static const String routeName = '/player';

  final TrackEntity track;
  final List<TrackEntity> queue;
  final bool autoPlayOnOpen;

  static Route<void> createRoute({
    required TrackEntity track,
    required List<TrackEntity> queue,
    bool autoPlayOnOpen = true,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => PlayerPage(
        track: track,
        queue: queue,
        autoPlayOnOpen: autoPlayOnOpen,
      ),
    );
  }

  const PlayerPage({
    super.key,
    required this.track,
    this.queue = const [],
    this.autoPlayOnOpen = true,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  double? _dragPositionMs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<PlayerBloc>();
      final currentTrack = bloc.state.currentTrack;
      if (!widget.autoPlayOnOpen &&
          currentTrack != null &&
          currentTrack.externalId == widget.track.externalId) {
        return;
      }
      final idx = widget.queue.indexOf(widget.track);
      bloc.add(
        PlayerPlay(
          track: widget.track,
          queue: widget.queue,
          startIndex: idx >= 0 ? idx : 0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxArtworkSize = MediaQuery.sizeOf(context).width * 0.75;
            final artworkSize = maxArtworkSize
                .clamp(180.0, constraints.maxHeight * 0.34)
                .toDouble();

            return Column(
              children: [
                // Top Bar
                _buildTopBar(context),

                const Spacer(),

                BlocSelector<PlayerBloc, PlayerState, (TrackEntity, bool)>(
                  selector: (state) =>
                      (state.currentTrack ?? widget.track, state.isFavorite),
                  builder: (context, data) {
                    final currentTrack = data.$1;
                    final isFavorite = data.$2;

                    return Column(
                      children: [
                        // Artwork
                        _buildArtwork(context, currentTrack, artworkSize),

                        const SizedBox(height: 24),

                        // Track Info
                        _buildTrackInfo(context, currentTrack, isFavorite),

                        const SizedBox(height: 16),

                        // Extra actions (lyrics, queue)
                        _buildExtraActions(context, currentTrack),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                BlocSelector<PlayerBloc, PlayerState, (Duration, Duration)>(
                  selector: (state) => (state.position, state.duration),
                  builder: (context, progress) {
                    return _buildProgressBar(context, progress.$1, progress.$2);
                  },
                ),

                const SizedBox(height: 16),

                BlocSelector<
                  PlayerBloc,
                  PlayerState,
                  (PlayerStatus, bool, bool)
                >(
                  selector: (state) =>
                      (state.status, state.hasPrevious, state.hasNext),
                  builder: (context, controlState) {
                    return _buildControls(
                      context,
                      status: controlState.$1,
                      hasPrevious: controlState.$2,
                      hasNext: controlState.$3,
                    );
                  },
                ),

                const Spacer(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Đang phát',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, size: 24),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(
    BuildContext context,
    TrackEntity currentTrack,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: currentTrack.artworkUrl != null
            ? CachedNetworkImage(
                imageUrl: currentTrack.artworkUrl!,
                fit: BoxFit.cover,
                memCacheWidth: 720,
                memCacheHeight: 720,
                placeholder: (context, url) => Container(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  child: const Icon(
                    Icons.music_note,
                    size: 80,
                    color: AppColors.grey,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  child: const Icon(
                    Icons.music_note,
                    size: 80,
                    color: AppColors.grey,
                  ),
                ),
              )
            : Container(
                color: AppColors.grey.withValues(alpha: 0.3),
                child: const Icon(
                  Icons.music_note,
                  size: 80,
                  color: AppColors.grey,
                ),
              ),
      ),
    );
  }

  Widget _buildTrackInfo(
    BuildContext context,
    TrackEntity currentTrack,
    bool isFavorite,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentTrack.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentTrack.artistName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 15, color: AppColors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.primary : AppColors.grey,
              size: 28,
            ),
            onPressed: () =>
                context.read<PlayerBloc>().add(PlayerToggleFavorite()),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    Duration position,
    Duration duration,
  ) {
    final posMs = position.inMilliseconds.toDouble();
    final durMs = duration.inMilliseconds.toDouble();
    final value = durMs > 0 ? posMs.clamp(0.0, durMs) : 0.0;
    final displayValue = durMs > 0
        ? (_dragPositionMs?.clamp(0.0, durMs) ?? value)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.inactiveSeekColor,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: displayValue,
              max: durMs > 0 ? durMs : 1.0,
              onChangeStart: (val) {
                setState(() => _dragPositionMs = val);
              },
              onChanged: (val) {
                setState(() => _dragPositionMs = val);
              },
              onChangeEnd: (val) {
                setState(() => _dragPositionMs = null);
                context.read<PlayerBloc>().add(
                  PlayerSeek(Duration(milliseconds: val.toInt())),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(
    BuildContext context, {
    required PlayerStatus status,
    required bool hasPrevious,
    required bool hasNext,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous
        IconButton(
          icon: Icon(
            Icons.skip_previous,
            size: 36,
            color: hasPrevious ? null : AppColors.grey,
          ),
          onPressed: hasPrevious
              ? () => context.read<PlayerBloc>().add(PlayerPrevious())
              : null,
        ),

        const SizedBox(width: 16),

        // Play / Pause
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: status == PlayerStatus.loading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                )
              : IconButton(
                  icon: Icon(
                    status == PlayerStatus.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                    size: 32,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (status == PlayerStatus.playing) {
                      context.read<PlayerBloc>().add(PlayerPause());
                    } else {
                      context.read<PlayerBloc>().add(PlayerResume());
                    }
                  },
                ),
        ),

        const SizedBox(width: 16),

        // Next
        IconButton(
          icon: Icon(
            Icons.skip_next,
            size: 36,
            color: hasNext ? null : AppColors.grey,
          ),
          onPressed: hasNext
              ? () => context.read<PlayerBloc>().add(PlayerNext())
              : null,
        ),
      ],
    );
  }

  Widget _buildExtraActions(BuildContext context, TrackEntity currentTrack) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.lyrics_outlined,
              color: context.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => LyricsSheet(
                  artist: currentTrack.artistName,
                  title: currentTrack.title,
                ),
              );
            },
            tooltip: 'Lời bài hát',
          ),
          IconButton(
            icon: Icon(
              Icons.comment_outlined,
              color: context.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CommentSheet(
                  trackExternalId: currentTrack.externalId,
                ),
              );
            },
            tooltip: 'Bình luận',
          ),
          IconButton(
            icon: Icon(
              Icons.playlist_add,
              color: context.isDarkMode ? Colors.white70 : Colors.black54,
            ),
            onPressed: () => _handleAddToPlaylist(currentTrack),
            tooltip: 'Thêm vào playlist',
          ),
        ],
      ),
    );
  }

  List<PlaylistEntity>? _playlistsFromState(LibraryState state) {
    if (state is LibraryLoaded) {
      return state.playlists;
    }
    if (state is LibraryRefreshing) {
      return state.playlists;
    }
    return null;
  }

  Future<List<PlaylistEntity>?> _ensurePlaylists(
    LibraryBloc libraryBloc,
  ) async {
    final currentPlaylists = _playlistsFromState(libraryBloc.state);
    if (currentPlaylists != null) {
      return currentPlaylists;
    }

    libraryBloc.add(LibraryLoad());
    var latestState = libraryBloc.state;

    final resolvedState = await libraryBloc.stream
        .firstWhere((state) {
          latestState = state;
          return _playlistsFromState(state) != null || state is LibraryError;
        })
        .timeout(const Duration(seconds: 5), onTimeout: () => latestState);

    return _playlistsFromState(resolvedState);
  }

  Future<void> _handleAddToPlaylist(TrackEntity track) async {
    final libraryBloc = context.read<LibraryBloc>();
    final playlists = await _ensurePlaylists(libraryBloc);

    if (!mounted) {
      return;
    }

    if (playlists == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Khong the tai thu vien. Vui long thu lai.'),
        ),
      );
      return;
    }

    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ban chua co playlist nao.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return ListTile(
                leading: const Icon(Icons.queue_music),
                title: Text(playlist.name),
                subtitle: Text('${playlist.trackCount} bai hat'),
                onTap: () {
                  libraryBloc.add(
                    LibraryAddTrackToPlaylist(
                      playlistId: playlist.id,
                      trackExternalId: track.externalId,
                    ),
                  );
                  Navigator.of(sheetContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Đã thêm vào ${playlist.name}.')),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
