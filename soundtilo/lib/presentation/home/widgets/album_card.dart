import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/presentation/home/models/local_album.dart';

class AlbumCard extends StatelessWidget {
  final LocalAlbum album;
  final VoidCallback onTap;

  const AlbumCard({
    required this.album,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: album.coverImageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.darkGrey,
                    child: const Icon(Icons.album, color: Colors.white, size: 50),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              album.title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              album.artistName,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: Color(0xffC6C6C6),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
