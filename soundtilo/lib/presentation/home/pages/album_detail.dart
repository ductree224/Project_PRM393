import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/presentation/home/models/local_album.dart';
import 'package:soundtilo/presentation/library/bloc/library_bloc.dart';
import 'package:soundtilo/presentation/player/pages/player.dart';

class AlbumDetailPage extends StatelessWidget {
  final LocalAlbum album;

  const AlbumDetailPage({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Album'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildControls(context),
            _buildTrackList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 100, bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.6),
            context.isDarkMode ? Colors.black : Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: album.coverImageUrl,
              height: 250,
              width: 250,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                height: 250,
                width: 250,
                color: AppColors.darkGrey,
                child: const Icon(Icons.album, size: 100, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              album.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${album.artistName} • ${album.tracks.length} bài hát, ${album.formattedTotalDuration}',
              style: TextStyle(
                fontSize: 14,
                color: context.isDarkMode ? Colors.grey[400] : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 50),
      itemCount: album.tracks.length,
      itemBuilder: (context, index) {
        final track = album.tracks[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: SizedBox(
            width: 30,
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 16,
                  color: context.isDarkMode ? Colors.grey[400] : Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          title: Text(
            track.title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            track.artistName,
            style: TextStyle(
              fontSize: 13,
              color: context.isDarkMode ? Colors.grey[400] : Colors.black54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            track.formattedDuration,
            style: TextStyle(
              fontSize: 13,
              color: context.isDarkMode ? Colors.grey[400] : Colors.black54,
            ),
          ),
          onTap: () => _playTrack(context, track),
        );
      },
    );
  }

  void _playTrack(BuildContext context, TrackEntity track) {
    final libraryBloc = context.read<LibraryBloc>();
    Navigator.push(
      context,
      PlayerPage.createRoute(
        track: track,
        queue: album.tracks,
        libraryBloc: libraryBloc,
      ),
    );
  }
}
