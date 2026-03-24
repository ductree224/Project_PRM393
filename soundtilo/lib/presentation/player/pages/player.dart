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
// BỔ SUNG: Import các file của Waitlist
import 'package:soundtilo/presentation/library/bloc/waitlist/waitlist_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/waitlist/waitlist_event.dart';
import 'package:soundtilo/presentation/library/bloc/waitlist/waitlist_state.dart';
import 'package:soundtilo/presentation/player/widgets/mini_equalizer.dart';

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
  late TrackEntity _displayTrack; // BỔ SUNG: Biến lưu bài hát đang được xem trên màn hình

  @override
  void initState() {
    super.initState();
    _displayTrack = widget.track; // Ban đầu hiển thị đúng bài vừa bấm vào

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final bloc = context.read<PlayerBloc>();

      // Kiểm tra xem hiện tại CÓ ĐANG PHÁT BÀI NÀO KHÁC KHÔNG
      final isPlayingSomethingElse = bloc.state.currentTrack != null;

      // Nếu autoPlayOnOpen = true VÀ KHÔNG CÓ NHẠC ĐANG PHÁT -> tự động phát
      if (widget.autoPlayOnOpen && !isPlayingSomethingElse) {
        final idx = widget.queue.indexOf(widget.track);
        bloc.add(
          PlayerPlay(
            track: widget.track,
            queue: widget.queue,
            startIndex: idx >= 0 ? idx : 0,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // BỔ SUNG: Lắng nghe sự thay đổi nhạc để cập nhật màn hình
        child: BlocListener<PlayerBloc, PlayerState>(
          listenWhen: (prev, curr) => prev.currentTrack?.externalId != curr.currentTrack?.externalId && curr.currentTrack != null,
          listener: (context, state) {
            setState(() {
              _displayTrack = state.currentTrack!; // Nhạc chuyển -> Đổi luôn giao diện hiển thị
            });
          },
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

                  // CẬP NHẬT: Dùng _displayTrack thay cho state.currentTrack
                  BlocSelector<PlayerBloc, PlayerState, bool>(
                    selector: (state) => state.isFavorite,
                    builder: (context, isFavorite) {
                      return Column(
                        children: [
                          // Artwork
                          _buildArtwork(context, _displayTrack, artworkSize),

                          const SizedBox(height: 24),

                          // Track Info
                          _buildTrackInfo(context, _displayTrack, isFavorite),

                          const SizedBox(height: 16),

                          // Extra actions (lyrics, queue)
                          _buildExtraActions(context, _displayTrack),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  BlocBuilder<PlayerBloc, PlayerState>(
                    builder: (context, state) {
                      // Kiểm tra xem bài đang hiển thị trên màn hình có khớp với bài đang phát ngầm không
                      final isViewingPlayingTrack = state.currentTrack?.externalId == _displayTrack.externalId;

                      // Nếu đang xem bài khác -> Ép thời gian về 00:00.
                      // Nếu đúng bài đang hát -> Lấy thời gian thực tế đang chạy
                      final displayPosition = isViewingPlayingTrack ? state.position : Duration.zero;
                      final displayDuration = isViewingPlayingTrack ? state.duration : Duration.zero;

                      return _buildProgressBar(context, displayPosition, displayDuration);
                    },
                  ),

                  const SizedBox(height: 16),

                  BlocSelector<
                      PlayerBloc,
                      PlayerState,
                      (PlayerStatus, bool, bool, TrackEntity?)
                  >(
                    selector: (state) => (
                    state.status,
                    state.hasPrevious,
                    state.hasNext,
                    state.currentTrack
                    ),
                    builder: (context, controlState) {
                      return _buildControls(
                        context,
                        status: controlState.$1,
                        hasPrevious: controlState.$2,
                        hasNext: controlState.$3,
                        currentTrack: controlState.$4, // Có thể null
                      );
                    },
                  ),

                  const Spacer(),
                ],
              );
            },
          ),
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
                  style: const TextStyle(fontSize: 15, color: AppColors.grey),
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
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
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
        required TrackEntity? currentTrack,
      }) {
    // KIỂM TRA: Bài hát đang hiển thị có trùng với bài đang phát ngầm không
    final isViewingPlayingTrack = currentTrack?.externalId == _displayTrack.externalId;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // NÚT THÊM/XÓA DANH SÁCH CHỜ NẰM Ở BÊN TRÁI CÙNG (Dựa trên _displayTrack)
        BlocBuilder<WaitlistBloc, WaitlistState>(
          builder: (context, waitlistState) {
            int virtualPosition = -999;

            if (waitlistState is WaitlistLoaded) {
              final index = waitlistState.tracks.indexWhere(
                    (t) => t.externalId == _displayTrack.externalId,
              );
              if (index != -1) {
                virtualPosition = index - waitlistState.fadedCount;
              }
            }

            final isInWaitlist = virtualPosition >= 0;

            return IconButton(
              icon: isInWaitlist
                  ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    virtualPosition == 0
                        ? const MiniEqualizer()
                        : Text(
                      '$virtualPosition',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.check, size: 16, color: AppColors.primary),
                  ],
                ),
              )
                  : Icon(
                Icons.queue_play_next,
                size: 28,
                color: context.isDarkMode ? Colors.white70 : Colors.black54,
              ),
              onPressed: () {
                // KIỂM TRA: Bài đang hiển thị có phải là bài đang hát không?
                final isCurrentlyPlaying = currentTrack?.externalId == _displayTrack.externalId;

                if (isCurrentlyPlaying) {
                  // Đang phát -> CHẶN LẠI VÀ THÔNG BÁO
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bài hát đang phát không thể thêm vào danh sách chờ.'))
                  );
                } else {
                  // Các bài khác -> THÊM / HỦY bình thường
                  if (isInWaitlist) {
                    context.read<WaitlistBloc>().add(WaitlistRemoveTrack(_displayTrack.externalId));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã hủy khỏi danh sách chờ.')));
                  } else {
                    context.read<WaitlistBloc>().add(WaitlistAddTrack(_displayTrack.externalId));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã thêm vào danh sách chờ.')));
                  }
                }
              },
            );
          },
        ),

        const SizedBox(width: 12),

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

        // Play / Pause THÔNG MINH
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
          child: (status == PlayerStatus.loading && isViewingPlayingTrack)
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          )
              : IconButton(
            icon: Icon(
              (status == PlayerStatus.playing && isViewingPlayingTrack)
                  ? Icons.pause
                  : Icons.play_arrow,
              size: 32,
              color: Colors.white,
            ),
            onPressed: () {
              if (isViewingPlayingTrack) {
                // Đang xem bài phát ngầm -> Tạm dừng / Tiếp tục
                if (status == PlayerStatus.playing) {
                  context.read<PlayerBloc>().add(PlayerPause());
                } else {
                  context.read<PlayerBloc>().add(PlayerResume());
                }
              } else {
                // Đang xem bài mới tinh -> Chèn lên số 0 và Phát luôn
                context.read<WaitlistBloc>().add(WaitlistInsertAndPlay(_displayTrack));

                final wState = context.read<WaitlistBloc>().state;
                List<TrackEntity> newQueue = [_displayTrack];
                if (wState is WaitlistLoaded) {
                  newQueue = wState.tracks.sublist(wState.fadedCount);
                }
                context.read<PlayerBloc>().add(PlayerPlay(track: _displayTrack, queue: newQueue));
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

        const SizedBox(width: 12),
        const SizedBox(width: 48),
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
          content: Text('Không thể tải thư viện. Vui lòng thử lại.'),
        ),
      );
      return;
    }

    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa có playlist nào.')),
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
                subtitle: Text('${playlist.trackCount} bài hát'),
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