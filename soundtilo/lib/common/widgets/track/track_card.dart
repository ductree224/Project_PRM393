import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';

class TrackCard extends StatelessWidget {
  final TrackEntity track;
  final VoidCallback onTap;

  const TrackCard({
    super.key,
    required this.track,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 150,
                height: 150,
                child: track.artworkUrl != null
                    ? CachedNetworkImage(
                        imageUrl: track.artworkUrl!,
                        fit: BoxFit.cover,
                        memCacheWidth: 300,
                        memCacheHeight: 300,
                        placeholder: (_, __) => Container(
                          color: AppColors.grey.withOpacity(0.3),
                          child: const Icon(Icons.music_note, size: 40, color: AppColors.grey),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.grey.withOpacity(0.3),
                          child: const Icon(Icons.music_note, size: 40, color: AppColors.grey),
                        ),
                      )
                    : Container(
                        color: AppColors.grey.withOpacity(0.3),
                        child: const Icon(Icons.music_note, size: 40, color: AppColors.grey),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              track.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              track.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
