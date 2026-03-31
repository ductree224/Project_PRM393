import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';

class VideoAdPage extends StatefulWidget {
  const VideoAdPage({super.key});

  @override
  State<VideoAdPage> createState() => _VideoAdPageState();
}

class _VideoAdPageState extends State<VideoAdPage> {
  late VideoPlayerController _controller;
  Timer? _countdownTimer;
  Timer? _autoCloseTimer;
  int _skipCountdown = 5;

  @override
  void initState() {
    super.initState();

    // GỌI VIDEO TỪ TRONG PROJECT RA (Tốc độ ánh sáng, không lo lỗi mạng)
    _controller = VideoPlayerController.asset('assets/videos/quang_cao.mp4')
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _startTimers();
      }).catchError((error) {
        debugPrint("Lỗi tải video local: $error");
      });
  }

  void _startTimers() {
    // Đếm ngược 5 giây cho nút Skip (Bỏ qua)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_skipCountdown > 0) {
        if (mounted) setState(() => _skipCountdown--);
      } else {
        timer.cancel();
      }
    });

    // Tự động đóng quảng cáo sau đúng 30 giây
    _autoCloseTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        _controller.pause();
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _countdownTimer?.cancel();
    _autoCloseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Chặn thoát bằng phím Back
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Hiển thị Video Fullscreen (Tràn viền)
            if (_controller.value.isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover, // Cắt và lấp đầy màn hình điện thoại
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),

            // Nút Bỏ qua (Skip) ở góc trên bên phải
            Positioned(
              top: 0,
              right: 0,
              left: 0,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 20),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _skipCountdown > 0
                          ? Container(
                        key: const ValueKey('count'),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Bỏ qua sau $_skipCountdown',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      )
                          : ElevatedButton(
                        key: const ValueKey('skip_btn'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.4),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        onPressed: () {
                          _controller.pause();
                          Navigator.pop(context);
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Bỏ qua ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Icon(Icons.skip_next, size: 20)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Nhãn "Quảng cáo" nhỏ ở góc dưới
            Positioned(
              bottom: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20, left: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'QUẢNG CÁO',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}