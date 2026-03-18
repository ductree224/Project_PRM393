import 'package:flutter/material.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/repository/lyrics_repository.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';

class LyricsSheet extends StatefulWidget {
  final String artist;
  final String title;

  const LyricsSheet({
    super.key,
    required this.artist,
    required this.title,
  });

  @override
  State<LyricsSheet> createState() => _LyricsSheetState();
}

class _LyricsSheetState extends State<LyricsSheet> {
  late Future<String?> _lyricsFuture;

  @override
  void initState() {
    super.initState();
    _lyricsFuture = _fetchLyrics();
  }

  Future<String?> _fetchLyrics() async {
    final repo = sl<LyricsRepository>();
    final result = await repo.getLyrics(artist: widget.artist, title: widget.title);
    return result.fold(
      (error) => null,
      (lyrics) => lyrics,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: context.isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.artist,
                      style: TextStyle(fontSize: 14, color: AppColors.grey),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Lyrics content
              Expanded(
                child: FutureBuilder<String?>(
                  future: _lyricsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.data == null || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lyrics_outlined,
                                size: 48, color: AppColors.grey.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy lời bài hát',
                              style: TextStyle(color: AppColors.grey, fontSize: 16),
                            ),
                          ],
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        snapshot.data!,
                        style: const TextStyle(fontSize: 16, height: 1.8),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
