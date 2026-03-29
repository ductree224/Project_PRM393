import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/navigation/app_navigator.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/presentation/player/bloc/player_bloc.dart';
import 'package:soundtilo/presentation/player/bloc/player_event.dart';
import 'package:soundtilo/presentation/player/bloc/player_state.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';

class MiniPlayer extends StatelessWidget {
  static const double shellReservedHeight = 88;
  static const double _barHeight = 74;

  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PlayerBloc, PlayerState, (TrackEntity?, PlayerStatus, bool)>(
      selector: (state) => (state.currentTrack, state.status, state.isMiniPlayerHidden),
      builder: (context, data) {
        final track = data.$1;
        final status = data.$2;
        final isHidden = data.$3;
        final shouldShow =
            track != null &&
            status != PlayerStatus.idle &&
            status != PlayerStatus.error &&
            !isHidden;

        if (!shouldShow) {
          return const SizedBox.shrink();
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              final state = context.read<PlayerBloc>().state;
              final currentTrack = state.currentTrack;
              if (currentTrack == null) {
                return;
              }

              final queue = state.queue.isEmpty
                  ? <TrackEntity>[currentTrack]
                  : state.queue;
              final navigatorState = AppNavigator.key.currentState;
              if (navigatorState == null) {
                return;
              }

              navigatorState.push<void>(
                PlayerPage.createRoute(
                  track: currentTrack,
                  queue: queue,
                  autoPlayOnOpen: false,
                ),
              );
            },
            child: Container(
              height: _barHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.grey.withValues(alpha: 0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const _MiniPlayerProgressBar(),
                  Expanded(
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        _MiniPlayerArtwork(track: track),
                        const SizedBox(width: 10),
                        Expanded(child: _MiniPlayerText(track: track)),
                        const _MiniPlayerControls(),
                        const _MiniPlayerCloseButton(),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MiniPlayerCloseButton extends StatelessWidget {
  const _MiniPlayerCloseButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      iconSize: 20,
      splashRadius: 18,
      color: AppColors.grey,
      onPressed: () {
        context.read<PlayerBloc>().add(PlayerHideMiniPlayer());
      },
      icon: const Icon(Icons.close),
    );
  }
}

class _MiniPlayerProgressBar extends StatelessWidget {
  const _MiniPlayerProgressBar();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PlayerBloc, PlayerState, (Duration, Duration)>(
      selector: (state) => (state.position, state.duration),
      builder: (context, progress) {
        final totalMs = progress.$2.inMilliseconds;
        final playedMs = progress.$1.inMilliseconds;
        final ratio = totalMs > 0 ? (playedMs / totalMs).clamp(0.0, 1.0) : 0.0;

        return LinearProgressIndicator(
          value: ratio,
          minHeight: 3,
          backgroundColor: AppColors.grey.withValues(alpha: 0.22),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        );
      },
    );
  }
}

class _MiniPlayerArtwork extends StatelessWidget {
  final TrackEntity track;

  const _MiniPlayerArtwork({required this.track});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 44,
        height: 44,
        child: track.artworkUrl == null
            ? ColoredBox(
                color: AppColors.grey.withValues(alpha: 0.24),
                child: const Icon(
                  Icons.music_note,
                  size: 20,
                  color: AppColors.grey,
                ),
              )
            : CachedNetworkImage(
                imageUrl: track.artworkUrl!,
                fit: BoxFit.cover,
                memCacheWidth: 120,
                memCacheHeight: 120,
                placeholder: (context, url) => ColoredBox(
                  color: AppColors.grey.withValues(alpha: 0.24),
                  child: const Icon(
                    Icons.music_note,
                    size: 20,
                    color: AppColors.grey,
                  ),
                ),
                errorWidget: (context, url, error) => ColoredBox(
                  color: AppColors.grey.withValues(alpha: 0.24),
                  child: const Icon(
                    Icons.music_note,
                    size: 20,
                    color: AppColors.grey,
                  ),
                ),
              ),
      ),
    );
  }
}

class _MiniPlayerText extends StatelessWidget {
  final TrackEntity track;

  const _MiniPlayerText({required this.track});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          track.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          track.artistName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.grey.withValues(alpha: 0.9),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _MiniPlayerControls extends StatelessWidget {
  const _MiniPlayerControls();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PlayerBloc, PlayerState, (PlayerStatus, bool, bool)>(
      selector: (state) => (state.status, state.hasPrevious, state.hasNext),
      builder: (context, data) {
        final status = data.$1;
        final hasPrevious = data.$2;
        final hasNext = data.$3;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              iconSize: 20,
              splashRadius: 18,
              color: hasPrevious ? Colors.white : AppColors.grey,
              onPressed: hasPrevious
                  ? () => context.read<PlayerBloc>().add(PlayerPrevious())
                  : null,
              icon: const Icon(Icons.skip_previous),
            ),
            if (status == PlayerStatus.loading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              IconButton(
                iconSize: 24,
                splashRadius: 18,
                color: Colors.white,
                onPressed: () {
                  if (status == PlayerStatus.playing) {
                    context.read<PlayerBloc>().add(PlayerPause());
                  } else {
                    context.read<PlayerBloc>().add(PlayerResume());
                  }
                },
                icon: Icon(
                  status == PlayerStatus.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
              ),
            IconButton(
              iconSize: 20,
              splashRadius: 18,
              color: hasNext ? Colors.white : AppColors.grey,
              onPressed: hasNext
                  ? () => context.read<PlayerBloc>().add(PlayerNext())
                  : null,
              icon: const Icon(Icons.skip_next),
            ),
          ],
        );
      },
    );
  }
}
