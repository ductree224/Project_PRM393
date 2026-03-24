import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/presentation/library/bloc/waitlist/waitlist_bloc.dart';
import 'package:soundtilo/presentation/library/bloc/waitlist/waitlist_event.dart';
import 'package:soundtilo/presentation/library/bloc/waitlist/waitlist_state.dart';
import 'package:soundtilo/presentation/player/bloc/player_bloc.dart';
import 'package:soundtilo/presentation/player/bloc/player_event.dart';
import 'package:soundtilo/presentation/player/bloc/player_state.dart';
import 'package:soundtilo/presentation/player/widgets/mini_equalizer.dart';

class WaitlistPage extends StatefulWidget {
  const WaitlistPage({super.key});

  @override
  State<WaitlistPage> createState() => _WaitlistPageState();
}

class _WaitlistPageState extends State<WaitlistPage> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<WaitlistBloc>();
    if (bloc.state is WaitlistInitial) bloc.add(WaitlistLoad());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách chờ phát'), centerTitle: true),
      body: BlocBuilder<WaitlistBloc, WaitlistState>(
        builder: (context, waitlistState) {
          if (waitlistState is WaitlistLoading || waitlistState is WaitlistInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (waitlistState is WaitlistError) {
            return Center(child: Text(waitlistState.message, style: const TextStyle(color: AppColors.errorColor)));
          }

          if (waitlistState is WaitlistLoaded) {
            return BlocBuilder<PlayerBloc, PlayerState>(
                builder: (context, playerState) {
                  final tracks = waitlistState.tracks;

                  // ĐỒNG BỘ ĐỘNG: Lấy ID bài hát thực tế đang nằm trong Player
                  final currentPlayingId = playerState.currentTrack?.externalId;
                  final isPlayerPlaying = playerState.status == PlayerStatus.playing;

                  // Tự động tìm mốc bắt đầu của "Nhạc đang phát"
                  int actualFadedCount = waitlistState.fadedCount;
                  if (currentPlayingId != null) {
                    final playingIndex = tracks.indexWhere((t) => t.externalId == currentPlayingId);
                    if (playingIndex != -1) {
                      actualFadedCount = playingIndex;
                    }
                  }

                  if (tracks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.queue_music, size: 64, color: AppColors.grey.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          const Text('Danh sách chờ đang trống.', style: TextStyle(color: AppColors.grey)),
                        ],
                      ),
                    );
                  }

                  // CẮT BỎ HOÀN TOÀN LỊCH SỬ - Chỉ lấy từ bài Đang phát trở về sau
                  final activeTracks = tracks.sublist(actualFadedCount);
                  final historyTracks = tracks.sublist(0, actualFadedCount); // Giữ lại ngầm để lưu DB

                  return Column(
                    children: [
                      // NÚT PHÁT NHẠC TỔNG
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: activeTracks.isNotEmpty ? () {
                            context.read<PlayerBloc>().add(PlayerPlay(track: activeTracks.first, queue: activeTracks));
                          } : null,
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text('Phát nhạc', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),

                      // DANH SÁCH BÀI HÁT (Chỉ hiển thị bài Đang phát và Hàng đợi)
                      // DANH SÁCH BÀI HÁT (Hiển thị tất cả: Đã nghe, Đang phát, Hàng đợi)
                      Expanded(
                        child: ReorderableListView.builder(
                          itemCount: tracks.length, // Lấy toàn bộ danh sách thay vì chỉ lấy activeTracks
                          onReorder: (oldIndex, newIndex) {
                            if (newIndex > oldIndex) newIndex -= 1;

                            final tempTracks = List<TrackEntity>.from(tracks);
                            final track = tempTracks.removeAt(oldIndex);
                            tempTracks.insert(newIndex, track);

                            // Tự động dò lại vị trí của bài ĐANG PHÁT hiện tại sau khi kéo thả
                            int newFadedCount = actualFadedCount;
                            if (currentPlayingId != null) {
                              final newPlayingIndex = tempTracks.indexWhere((t) => t.externalId == currentPlayingId);
                              if (newPlayingIndex != -1) {
                                // Bài đang phát trôi đi đâu, mốc làm mờ sẽ tự động bám theo đến đó!
                                newFadedCount = newPlayingIndex;
                              }
                            }

                            final newOrderIds = tempTracks.map((t) => t.externalId).toList();

                            // Gửi thứ tự mới lên BLoC, tuyệt đối KHÔNG gọi context.read<PlayerBloc>().add(PlayerPlay(...)) ở đây nữa
                            context.read<WaitlistBloc>().add(WaitlistReorderTracks(newOrderIds, newFadedCount));
                          },
                          itemBuilder: (context, index) {
                            final track = tracks[index];
                            final isFaded = index < actualFadedCount; // Bài đứng trước là bài đã nghe -> Làm mờ
                            final isPlayingSlot = index == actualFadedCount; // Bài ở ranh giới là bài đang phát

                            // XÁC ĐỊNH ICON BÊN TRÁI
                            Widget leadingWidget;
                            if (isFaded) {
                              leadingWidget = const Icon(Icons.history, color: AppColors.grey, size: 18);
                            } else if (isPlayingSlot) {
                              if (isPlayerPlaying && track.externalId == currentPlayingId) {
                                leadingWidget = const MiniEqualizer();
                              } else {
                                leadingWidget = const Icon(Icons.pause_circle_filled, color: AppColors.primary, size: 20);
                              }
                            } else {
                              leadingWidget = Text('${index - actualFadedCount}', style: const TextStyle(color: AppColors.grey, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center);
                            }

                            return Dismissible(
                              key: ValueKey('dismiss_${track.externalId}'),
                              // Không cho quẹt xóa bài đã làm mờ (lịch sử)
                              direction: isFaded ? DismissDirection.none : DismissDirection.endToStart,
                              onDismissed: (_) {
                                context.read<WaitlistBloc>().add(WaitlistRemoveTrack(track.externalId));
                              },
                              background: Container(
                                color: AppColors.errorColor, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              // LÀM MỜ BÀI ĐÃ NGHE Ở ĐÂY
                              child: Opacity(
                                opacity: isFaded ? 0.4 : 1.0,
                                child: ListTile(
                                  key: ValueKey('listTile_${track.externalId}'),
                                  onTap: () {
                                    if (isPlayingSlot) {
                                      // Ấn vào bài đang phát -> Play/Pause
                                      if (isPlayerPlaying) {
                                        context.read<PlayerBloc>().add(PlayerPause());
                                      } else {
                                        context.read<PlayerBloc>().add(PlayerResume());
                                      }
                                    } else {
                                      // GIỮ NGUYÊN THỨ TỰ, CHỈ CẬP NHẬT SỐ LƯỢNG BÀI MỜ
                                      // Vị trí anh/chị bấm vào (index) chính là số lượng bài bị làm mờ mới
                                      final currentTrackIds = tracks.map((t) => t.externalId).toList();
                                      context.read<WaitlistBloc>().add(WaitlistReorderTracks(currentTrackIds, index));

                                      // Lấy danh sách phát từ bài được chọn trở về cuối
                                      final activeQueue = tracks.sublist(index);

                                      // Gọi Player phát nhạc
                                      context.read<PlayerBloc>().add(PlayerPlay(track: track, queue: activeQueue));
                                    }
                                  },
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(width: 24, child: leadingWidget),
                                      const SizedBox(width: 12),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.network(track.artworkUrl ?? '', width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.music_note)),
                                      ),
                                    ],
                                  ),
                                  title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: isPlayingSlot ? AppColors.primary : null, fontWeight: isPlayingSlot ? FontWeight.bold : null)),
                                  subtitle: Text(track.artistName, maxLines: 1, overflow: TextOverflow.ellipsis),
                                  trailing: isFaded ? null : const Icon(Icons.drag_handle, color: AppColors.grey), // Ẩn tay cầm kéo thả ở bài đã mờ
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}