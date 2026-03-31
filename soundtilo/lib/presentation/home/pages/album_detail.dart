import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/presentation/home/models/local_album.dart';
import 'package:soundtilo/data/models/track_model.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';
import 'package:soundtilo/presentation/player/widgets/mini_player.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../domain/repositories/album_repository.dart';

class AlbumDetailPage extends StatefulWidget {
  final LocalAlbum album;

  const AlbumDetailPage({super.key, required this.album});

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  late LocalAlbum _currentAlbum;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _currentAlbum = widget.album;
    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    final result = await sl<AlbumRepository>().getAlbumById(_currentAlbum.id, includeTracks: true);
    
    if (mounted) {
      result.fold(
        (error) => setState(() {
          _error = error;
          _isLoading = false;
        }),
        (albumModel) {
          setState(() {
            _currentAlbum = LocalAlbum(
              id: albumModel.id,
              title: albumModel.title,
              artistName: albumModel.artist?.name ?? 'Unknown',
              coverImageUrl: albumModel.coverImageUrl ?? '',
              tracks: albumModel.tracks.map((at) => at.track ?? TrackModel(
                externalId: at.trackExternalId,
                source: 'audius',
                title: 'Unknown Track',
                artistName: albumModel.artist?.name ?? 'Unknown',
                durationSeconds: 0,
              )).toList(),
            );
            _isLoading = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                if (_isLoading)
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: 16),
                          Text('Đang tải danh sách bài hát...', style: TextStyle(color: context.isDarkMode ? Colors.grey : Colors.black54)),
                        ],
                      ),
                    ),
                  )
                else if (_error != null)
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                            const SizedBox(height: 16),
                            Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            ElevatedButton(onPressed: _fetchFullDetails, child: const Text('Thử lại')),
                          ],
                        ),
                      ),
                    ),
                  )
                else ...[
                  _buildControls(context),
                  _buildTrackList(context),
                ],
              ],
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: const MiniPlayer(),
          ),
          Positioned(
            right: 16,
            bottom: 8,
            child: const MiniPlayerShowButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String? url, {double height = 250, double width = 250}) {
    if (url == null || url.isEmpty) {
      return _buildPlaceholderImage(height, width);
    }

    try {
      final uri = Uri.parse(url);
      if (uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https')) {
        return CachedNetworkImage(
          imageUrl: url,
          height: height,
          width: width,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholderImage(height, width),
          errorWidget: (context, url, error) => _buildPlaceholderImage(height, width),
        );
      }
      return _buildPlaceholderImage(height, width);
    } catch (e) {
      return _buildPlaceholderImage(height, width);
    }
  }

  Widget _buildPlaceholderImage(double height, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.darkGrey,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkGrey, Colors.grey[800]!],
        ),
      ),
      child: Icon(Icons.music_note, size: height * 0.4, color: Colors.white24),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final album = _currentAlbum;
    final primaryColor = AppColors.primary;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 100, bottom: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor.withValues(alpha: 0.8),
            primaryColor.withValues(alpha: 0.2),
            context.isDarkMode ? Colors.black : Colors.white,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(album.coverImageUrl),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              album.title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
                color: context.isDarkMode ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  album.artistName,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  ' • ${album.tracks.length} bài hát',
                  style: TextStyle(
                    fontSize: 14,
                    color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (album.totalDurationSeconds > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                album.formattedTotalDuration,
                style: TextStyle(
                  fontSize: 12,
                  color: context.isDarkMode ? Colors.grey[600] : Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final album = _currentAlbum;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          onTap: () {
            if (album.tracks.isNotEmpty) {
              _playTrack(context, album.tracks.first);
            }
          },
          child: Container(
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackList(BuildContext context) {
    final album = _currentAlbum;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: album.tracks.length,
      itemBuilder: (context, index) {
        final track = album.tracks[index];
        return Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            leading: SizedBox(
              width: 30,
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    color: context.isDarkMode ? Colors.grey[600] : Colors.black38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              track.title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: context.isDarkMode ? Colors.white : Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              track.artistName,
              style: TextStyle(
                fontSize: 13,
                color: context.isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  track.formattedDuration,
                  style: TextStyle(
                    fontSize: 13,
                    color: context.isDarkMode ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.more_vert, color: context.isDarkMode ? Colors.grey[700] : Colors.grey[300]),
              ],
            ),
            onTap: () => _playTrack(context, track),
          ),
        );
      },
    );
  }

  void _playTrack(BuildContext context, TrackEntity track) {
    final album = _currentAlbum;
    Navigator.push(
      context,
      PlayerPage.createRoute(
        track: track,
        queue: album.tracks,
      ),
    );
  }
}
