import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/entities/playlist_detail_entity.dart';
import 'package:soundtilo/domain/entities/playlist_track_entity.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/usecases/playlist_usecases.dart';
import 'package:soundtilo/domain/usecases/track_usecases.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/library_event.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';

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
  bool _isLoadingTracks = false;
  bool _isSavingOrder = false;
  String? _errorMessage;
  PlaylistDetailEntity? _playlist;
  List<TrackEntity> _resolvedTracks = const [];

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
    if (!mounted) return;

    result.fold(
      (error) => setState(() {
        _errorMessage = error;
        _isLoading = false;
      }),
      (playlistDetail) async {
        setState(() {
          _playlist = playlistDetail;
          _isLoading = false;
          _isLoadingTracks = true;
        });
        final tracks = await _fetchTracks(playlistDetail.tracks);
        if (!mounted) return;
        setState(() {
          _resolvedTracks = tracks;
          _isLoadingTracks = false;
        });
      },
    );
  }

  Future<List<TrackEntity>> _fetchTracks(
      List<PlaylistTrackEntity> tracks) async {
    if (tracks.isEmpty) return const [];

    final ids = tracks.map((t) => t.trackExternalId).toList(growable: false);
    final results = await Future.wait(ids.map(_getTrackUseCase.call));

    final byId = <String, TrackEntity>{};
    for (final r in results) {
      r.fold((_) {}, (track) => byId[track.externalId] = track);
    }

    return ids
        .map((id) =>
            byId[id] ??
            TrackEntity(
              externalId: id,
              source: 'audius',
              title: id,
              artistName: '',
              durationSeconds: 0,
            ))
        .toList(growable: false);
  }

  void _openPlayer(int index) {
    if (_resolvedTracks.isEmpty || index >= _resolvedTracks.length) return;
    Navigator.push(
      context,
      PlayerPage.createRoute(
        track: _resolvedTracks[index],
        queue: _resolvedTracks,
      ),
    );
  }

  void _removeTrack(String trackExternalId) {
    final current = _playlist;
    if (current == null) return;

    final newPlaylistTracks = current.tracks
        .where((t) => t.trackExternalId != trackExternalId)
        .toList(growable: false);
    final newResolved = _resolvedTracks
        .where((t) => t.externalId != trackExternalId)
        .toList(growable: false);

    setState(() {
      _playlist = PlaylistDetailEntity(
        id: current.id,
        name: current.name,
        description: current.description,
        isPublic: current.isPublic,
        tracks: newPlaylistTracks,
        createdAt: current.createdAt,
        updatedAt: current.updatedAt,
      );
      _resolvedTracks = newResolved;
    });

    context.read<LibraryBloc>().add(LibraryRemoveTrackFromPlaylist(
          playlistId: widget.playlistId,
          trackExternalId: trackExternalId,
        ));
  }

  void _showAddTrackSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<LibraryBloc>(),
        child: _AddTrackSheet(
          playlistId: widget.playlistId,
          onTrackAdded: _loadPlaylistDetail,
        ),
      ),
    );
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    final current = _playlist;
    if (current == null) return;

    final playlistTracks = current.tracks.toList(growable: true);
    final resolved = _resolvedTracks.toList(growable: true);
    if (newIndex > oldIndex) newIndex -= 1;

    final movedPt = playlistTracks.removeAt(oldIndex);
    playlistTracks.insert(newIndex, movedPt);

    if (oldIndex < resolved.length) {
      final movedT = resolved.removeAt(oldIndex);
      if (newIndex <= resolved.length) resolved.insert(newIndex, movedT);
    }

    setState(() {
      _playlist = PlaylistDetailEntity(
        id: current.id,
        name: current.name,
        description: current.description,
        isPublic: current.isPublic,
        tracks: playlistTracks,
        createdAt: current.createdAt,
        updatedAt: current.updatedAt,
      );
      _resolvedTracks = resolved;
      _isSavingOrder = true;
    });

    final ids =
        playlistTracks.map((t) => t.trackExternalId).toList(growable: false);
    final result = await _reorderTracksUseCase(widget.playlistId, ids);
    if (!mounted) return;

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error), backgroundColor: AppColors.errorColor),
        );
        _loadPlaylistDetail();
      },
      (_) => _loadPlaylistDetail(),
    );

    if (mounted) setState(() => _isSavingOrder = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_playlist?.name ?? 'Chi tiết playlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm bài hát',
            onPressed: _showAddTrackSheet,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

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
                  child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    final playlist = _playlist;
    if (playlist == null) return const SizedBox.shrink();

    if (playlist.tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Playlist chưa có bài hát nào.'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Thêm bài hát'),
              onPressed: _showAddTrackSheet,
            ),
          ],
        ),
      );
    }

    if (_isLoadingTracks) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        ReorderableListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: playlist.tracks.length,
          onReorder: _onReorder,
          itemBuilder: (context, index) {
            final playlistTrack = playlist.tracks[index];
            final track = index < _resolvedTracks.length
                ? _resolvedTracks[index]
                : TrackEntity(
                    externalId: playlistTrack.trackExternalId,
                    source: 'audius',
                    title: playlistTrack.trackExternalId,
                    artistName: '',
                    durationSeconds: 0,
                  );

            return _TrackRow(
              key: ValueKey(
                  '${playlistTrack.trackExternalId}-${playlistTrack.position}'),
              track: track,
              onTap: () => _openPlayer(index),
              onRemove: () => _removeTrack(playlistTrack.trackExternalId),
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

// --------------------------------------------------------------------------

class _TrackRow extends StatelessWidget {
  final TrackEntity track;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _TrackRow({
    super.key,
    required this.track,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 52,
          height: 52,
          child: track.artworkUrl != null
              ? CachedNetworkImage(
                  imageUrl: track.artworkUrl!,
                  fit: BoxFit.cover,
                  memCacheWidth: 104,
                  memCacheHeight: 104,
                  placeholder: (context, url) => const _ArtworkPlaceholder(),
                  errorWidget: (context, url, error) => const _ArtworkPlaceholder(),
                )
              : const _ArtworkPlaceholder(),
        ),
      ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        track.artistName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12, color: AppColors.grey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            track.formattedDuration,
            style: const TextStyle(color: AppColors.grey, fontSize: 13),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            color: AppColors.errorColor,
            onPressed: onRemove,
            tooltip: 'Xóa khỏi playlist',
          ),
        ],
      ),
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: AppColors.grey.withValues(alpha: 0.3),
        child: const Icon(Icons.music_note, color: AppColors.grey),
      );
}

class _AddTrackSheet extends StatefulWidget {
  final String playlistId;
  final VoidCallback onTrackAdded;

  const _AddTrackSheet(
      {required this.playlistId, required this.onTrackAdded});

  @override
  State<_AddTrackSheet> createState() => _AddTrackSheetState();
}

class _AddTrackSheetState extends State<_AddTrackSheet> {
  final SearchTracksUseCase _searchUseCase = sl<SearchTracksUseCase>();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  List<TrackEntity> _results = const [];
  bool _isSearching = false;
  String? _searchError;
  final Set<String> _addedIds = {};

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final query = value.trim();
    if (query.isEmpty) {
      setState(() {
        _results = const [];
        _isSearching = false;
        _searchError = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final result = await _searchUseCase(query);
      if (!mounted) return;
      result.fold(
        (error) => setState(() {
          _searchError = error;
          _isSearching = false;
        }),
        (tracks) => setState(() {
          _results = tracks;
          _isSearching = false;
        }),
      );
    });
  }

  void _addTrack(TrackEntity track) {
    if (_addedIds.contains(track.externalId)) return;
    setState(() => _addedIds.add(track.externalId));

    context.read<LibraryBloc>().add(LibraryAddTrackToPlaylist(
          playlistId: widget.playlistId,
          trackExternalId: track.externalId,
        ));

    widget.onTrackAdded();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm "${track.title}" vào playlist')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Tìm bài hát...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: _onChanged,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _buildResults(scrollController)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(ScrollController scrollController) {
    if (_isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_searchError != null) {
      return Center(
          child: Text(_searchError!,
              style: const TextStyle(color: AppColors.errorColor)));
    }
    if (_controller.text.trim().isEmpty) {
      return const Center(
          child: Text('Nhập tên bài hát để tìm kiếm',
              style: TextStyle(color: AppColors.grey)));
    }
    if (_results.isEmpty) {
      return const Center(
          child: Text('Không tìm thấy kết quả',
              style: TextStyle(color: AppColors.grey)));
    }

    return ListView.builder(
      controller: scrollController,
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final track = _results[index];
        final added = _addedIds.contains(track.externalId);
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 48,
              height: 48,
              child: track.artworkUrl != null
                  ? CachedNetworkImage(
                      imageUrl: track.artworkUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const _ArtworkPlaceholder(),
                      errorWidget: (context, url, error) =>
                          const _ArtworkPlaceholder(),
                    )
                  : const _ArtworkPlaceholder(),
            ),
          ),
          title: Text(track.title,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(track.artistName,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: added
              ? const Icon(Icons.check_circle, color: AppColors.primary)
              : IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.primary),
                  onPressed: () => _addTrack(track),
                ),
        );
      },
    );
  }
}
