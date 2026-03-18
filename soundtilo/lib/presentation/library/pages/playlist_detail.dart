import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/entities/playlist_detail_entity.dart';
import 'package:soundtilo/domain/entities/playlist_track_entity.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/usecases/playlist_usecases.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';

class PlaylistDetailPage extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailPage({super.key, required this.playlistId});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  final GetPlaylistDetailUseCase _getPlaylistDetailUseCase =
      sl<GetPlaylistDetailUseCase>();
  final GetTrackUseCase _getTrackUseCase = sl<GetTrackUseCase>();
  final ReorderTracksInPlaylistUseCase _reorderTracksUseCase =
      sl<ReorderTracksInPlaylistUseCase>();

  bool _isLoading = true;
  bool _isSavingOrder = false;
  String? _errorMessage;
  PlaylistDetailEntity? _playlist;
  Future<List<TrackEntity>> _tracksFuture = Future.value(
    const <TrackEntity>[],
  );

  @override
  void initState() {
    super.initState();
    _loadPlaylistDetail();
  }

  Future<void> _loadPlaylistDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _getPlaylistDetailUseCase(widget.playlistId);
    if (!mounted) {
      return;
    }

    result.fold(
      (error) {
        setState(() {
          _errorMessage = error;
          _isLoading = false;
        });
      },
      (playlistDetail) {
        setState(() {
          _playlist = playlistDetail;
          _tracksFuture = _loadTracks(playlistDetail.tracks);
          _isLoading = false;
        });
      },
    );
  }

  Future<List<TrackEntity>> _loadTracks(List<PlaylistTrackEntity> tracks) async {
    if (tracks.isEmpty) {
      return const <TrackEntity>[];
    }

    final ids = tracks
        .map((track) => track.trackExternalId)
        .toList(growable: false);
    final results = await Future.wait(ids.map(_getTrackUseCase.call));

    final tracksById = <String, TrackEntity>{};
    for (final result in results) {
      result.fold(
        (_) {},
        (track) {
          tracksById[track.externalId] = track;
        },
      );
    }

    return ids
        .map(
          (id) => tracksById[id] ??
              TrackEntity(
                externalId: id,
                source: 'audius',
                title: id,
                artistName: '',
                durationSeconds: 0,
              ),
        )
        .toList(growable: false);
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final current = _playlist;
    if (current == null) {
      return;
    }

    final tracks = current.tracks.toList(growable: true);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final movedTrack = tracks.removeAt(oldIndex);
    tracks.insert(newIndex, movedTrack);

    setState(() {
      _playlist = PlaylistDetailEntity(
        id: current.id,
        name: current.name,
        description: current.description,
        coverImageUrl: current.coverImageUrl,
        isPublic: current.isPublic,
        tracks: tracks,
        createdAt: current.createdAt,
        updatedAt: current.updatedAt,
      );
      _tracksFuture = _loadTracks(tracks);
      _isSavingOrder = true;
    });

    final ids = tracks
        .map((track) => track.trackExternalId)
        .toList(growable: false);
    final result = await _reorderTracksUseCase(widget.playlistId, ids);
    if (!mounted) {
      return;
    }

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.errorColor),
        );
        _loadPlaylistDetail();
      },
      (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật thứ tự playlist.')),
        );
        _loadPlaylistDetail();
      },
    );

    if (mounted) {
      setState(() {
        _isSavingOrder = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_playlist?.name ?? 'Chi tiết playlist')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.errorColor),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadPlaylistDetail,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final playlist = _playlist;
    if (playlist == null) {
      return const SizedBox.shrink();
    }

    if (playlist.tracks.isEmpty) {
      return const Center(child: Text('Playlist chưa có bài hát nào.'));
    }

    return Stack(
      children: [
        FutureBuilder<List<TrackEntity>>(
          future: _tracksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final tracks = snapshot.data ?? const <TrackEntity>[];
            return ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: playlist.tracks.length,
              onReorder: _onReorder,
              itemBuilder: (context, index) {
                final playlistTrack = playlist.tracks[index];
                final track = tracks[index];

                return ListTile(
                  key: ValueKey(
                    '${playlistTrack.trackExternalId}-${playlistTrack.position}',
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: track.artworkUrl != null
                          ? CachedNetworkImage(
                              imageUrl: track.artworkUrl!,
                              fit: BoxFit.cover,
                              memCacheWidth: 112,
                              memCacheHeight: 112,
                              placeholder: (_, __) => Container(
                                color: AppColors.grey.withOpacity(0.3),
                                child: const Icon(
                                  Icons.music_note,
                                  color: AppColors.grey,
                                ),
                              ),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.grey.withOpacity(0.3),
                                child: const Icon(
                                  Icons.music_note,
                                  color: AppColors.grey,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.grey.withOpacity(0.3),
                              child: const Icon(
                                Icons.music_note,
                                color: AppColors.grey,
                              ),
                            ),
                    ),
                  ),
                  title: Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(track.formattedDuration),
                );
              },
            );
          },
        ),
        if (_isSavingOrder)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }
}
