import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';

class TrackTile extends StatelessWidget {
  final TrackEntity track;
  final VoidCallback onTap;
  final VoidCallback? onMoreTap;
  final IconData trailingIcon;
  final Color? trailingIconColor;

  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    this.onMoreTap,
    this.trailingIcon = Icons.more_vert,
    this.trailingIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
                    child: const Icon(Icons.music_note, color: AppColors.grey),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.grey.withOpacity(0.3),
                    child: const Icon(Icons.music_note, color: AppColors.grey),
                  ),
                )
              : Container(
                  color: AppColors.grey.withOpacity(0.3),
                  child: const Icon(Icons.music_note, color: AppColors.grey),
                ),
        ),
      ),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Row(
        children: [
          if (!track.isFullStream)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('30s', style: TextStyle(fontSize: 10, color: AppColors.primary)),
            ),
          Expanded(
            child: Text(
              track.artistName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: AppColors.grey),
            ),
          ),
          Text(
            track.formattedDuration,
            style: TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
      trailing: onMoreTap != null
          ? IconButton(
              icon: Icon(trailingIcon, size: 20, color: trailingIconColor),
              onPressed: onMoreTap,
            )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
