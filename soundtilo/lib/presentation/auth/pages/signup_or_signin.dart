import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/presentation/auth/pages/signin.dart';
import 'package:soundtilo/presentation/auth/pages/signup.dart';

class SignupOrSigninPage extends StatelessWidget {
  const SignupOrSigninPage({super.key});

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
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.9),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2,),
                
                // 3. LOGO VỚI ANIMATION
                _DelayedWidget(
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

                const SizedBox(height: 40,),

                // 4. SLOGAN VỚI HIỆU ỨNG TRƯỢT
                _DelayedWidget(
                  delay: const Duration(milliseconds: 300),
                  child: TweenAnimationBuilder<Offset>(
                    tween: Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: value,
                        child: Opacity(
                          opacity: (1 - (value.dy / 20.0)).clamp(0.0, 1.0),
                          child: Text(
                            'Tận hưởng không gian\nnghe nhạc tuyệt vời',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 24,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15,),

                _DelayedWidget(
                  delay: const Duration(milliseconds: 500),
                  child: Text(
                    'Tham gia cộng đồng yêu nhạc lớn nhất Việt Nam.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                  ),
                ),

                const Spacer(flex: 3,),

                // 5. CỤM NÚT BẤM
                _DelayedWidget(
                  delay: const Duration(milliseconds: 700),
                  child: Row(
                    children: [
                      Expanded(
                        child: _BasicGradientAppButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SignUpPage()),
                            );
                          },
                          title: 'Đăng ký',
                        ),
                      ),
                      const SizedBox(width: 20,),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SignInPage()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            ),
                          ),
                          child: Text(
                            'Đăng nhập',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60,),
              ],
            ),
          ),
          
          // Back Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20,),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// REUSE CUSTOM WIDGETS (Đồng bộ hoàn toàn)
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
