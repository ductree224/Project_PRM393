import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/presentation/auth/pages/signup_or_signin.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. NỀN ĐỘNG (Đồng bộ)
          Positioned.fill(
            child: _SoundParticlesWidget(),
          ),
          
          // 2. LỚP PHỦ GRADIENT
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 40,
              horizontal: 30,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20,),
                // 3. LOGO VỚI ANIMATION
                Align(
                  alignment: Alignment.topCenter,
                  child: _DelayedWidget(
                    delay: const Duration(milliseconds: 100),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: SvgPicture.asset(
                              AppVectors.logo,
                              width: MediaQuery.of(context).size.width * 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const Spacer(),
                
                // 4. TIÊU ĐỀ
                _DelayedWidget(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Tận hưởng âm nhạc,\nđánh thức đam mê',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 26,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                
                const SizedBox(height: 21,),
                
                // 5. MÔ TẢ
                _DelayedWidget(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    'Khám phá kho âm nhạc khổng lồ\ndành riêng cho tâm hồn bạn.',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                const SizedBox(height: 40,),
                
                // 6. NÚT BẮT ĐẦU (Điều hướng thẳng tới SignupOrSignin)
                _DelayedWidget(
                  delay: const Duration(milliseconds: 700),
                  child: _BasicGradientAppButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const SignupOrSigninPage()
                        )
                      );
                    },
                    title: 'Bắt đầu ngay',
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}

// --------------------------------------------------------------------------
// REUSE CUSTOM WIDGETS
// --------------------------------------------------------------------------
class _DelayedWidget extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _DelayedWidget({required this.child, required this.delay});
  @override
  State<_DelayedWidget> createState() => _DelayedWidgetState();
}

class _DelayedWidgetState extends State<_DelayedWidget> {
  bool _show = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () { if (mounted) setState(() => _show = true); });
  }
  @override
  Widget build(BuildContext context) {
    return _show ? widget.child : const SizedBox.shrink();
  }
}

class _SoundParticlesWidget extends StatefulWidget {
  @override
  _SoundParticlesWidgetState createState() => _SoundParticlesWidgetState();
}

class _SoundParticlesWidgetState extends State<_SoundParticlesWidget> with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final int _numberOfParticles = 70;
  final math.Random _random = math.Random();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    for (int i = 0; i < _numberOfParticles; i++) { _particles.add(_Particle(_random)); }
  }
  @override
  void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => CustomPaint(painter: _ParticlePainter(_particles, _controller.value)),
    );
  }
}

class _Particle {
  late double x, y, size, velocityY, velocityX, opacity;
  _Particle(math.Random random) {
    x = random.nextDouble(); y = random.nextDouble();
    size = random.nextDouble() * 3.5 + 1.5;
    velocityX = (random.nextDouble() - 0.5) * 0.002;
    velocityY = (random.nextDouble() - 0.5) * 0.002;
    opacity = random.nextDouble() * 0.5 + 0.2;
  }
  void update() {
    x += velocityX; y += velocityY;
    if (x < 0 || x > 1.0) velocityX *= -1;
    if (y < 0 || y > 1.0) velocityY *= -1;
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;
  _ParticlePainter(this.particles, this.animationValue);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    for (final p in particles) {
      p.update();
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), p.size, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BasicGradientAppButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String title;
  const _BasicGradientAppButton({required this.onPressed, required this.title});
  @override
  _BasicGradientAppButtonState createState() => _BasicGradientAppButtonState();
}

class _BasicGradientAppButtonState extends State<_BasicGradientAppButton> {
  double _scale = 1.0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) { setState(() => _scale = 1.0); widget.onPressed(); },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_scale),
        height: 55, width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.thirdly, AppColors.primary, AppColors.secondary],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Center(
          child: Text(widget.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 17)),
        ),
      ),
    );
  }
}
