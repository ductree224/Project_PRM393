import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/presentation/auth/pages/signup_or_signin.dart';
import 'package:soundtilo/presentation/choose_mode/bloc/theme_cubit.dart';

class ChooseModePage extends StatelessWidget {
  const ChooseModePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. NỀN ĐỘNG HIỆN ĐẠI (Đồng bộ hoàn toàn với GetStarted)
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
                  Colors.black.withOpacity(0.0),
                  Colors.black.withOpacity(0.9),
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
                
                // 3. LOGO VỚI HIỆU ỨNG XUẤT HIỆN
                Align(
                  alignment: Alignment.topCenter,
                  child: _DelayedWidget(
                    delay: const Duration(milliseconds: 100),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: SvgPicture.asset(
                            AppVectors.logo, 
                            width: MediaQuery.of(context).size.width * 0.45,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const Spacer(),

                // 4. TIÊU ĐỀ VỚI HIỆU ỨNG TRƯỢT
                _DelayedWidget(
                  delay: const Duration(milliseconds: 300),
                  child: TweenAnimationBuilder<Offset>(
                    tween: Tween<Offset>(begin: const Offset(0, 30), end: Offset.zero),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: value,
                        child: Opacity(
                          opacity: (1 - (value.dy / 30.0)).clamp(0.0, 1.0),
                          child: Text(
                            'Chọn chế độ hiển thị',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 26,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40,),

                // 5. LỰA CHỌN CHẾ ĐỘ
                _DelayedWidget(
                  delay: const Duration(milliseconds: 500),
                  child: BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, currentMode) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _ModeItem(
                            title: 'Chế độ Sáng',
                            icon: AppVectors.sun,
                            isActive: currentMode == ThemeMode.light,
                            onTap: () => context.read<ThemeCubit>().updateTheme(ThemeMode.light),
                          ),
                          const SizedBox(width: 40,),
                          _ModeItem(
                            title: 'Chế độ Tối',
                            icon: AppVectors.moon,
                            isActive: currentMode == ThemeMode.dark,
                            onTap: () => context.read<ThemeCubit>().updateTheme(ThemeMode.dark),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const Spacer(flex: 2,),

                // 6. NÚT TIẾP TỤC
                _DelayedWidget(
                  delay: const Duration(milliseconds: 700),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: _BasicGradientAppButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const SignupOrSigninPage()
                          )
                        );
                      },
                      title: 'Tiếp tục',
                    ),
                  ),
                ),

                const SizedBox(height: 20,),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------
// Custom Widget: Item chọn Mode (Giữ nguyên logic Glassmorphism của bạn)
// --------------------------------------------------------------------------
class _ModeItem extends StatelessWidget {
  final String title;
  final String icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeItem({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? const Color(0xFF6B4EEA) : Colors.transparent,
                width: 2,
              ),
              boxShadow: isActive ? [
                BoxShadow(
                  color: const Color(0xFF6B4EEA).withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ] : [],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: isActive 
                      ? const Color(0xFF6B4EEA).withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    icon,
                    fit: BoxFit.none,
                    colorFilter: ColorFilter.mode(
                      isActive ? Colors.white : AppColors.grey,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15,),
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: isActive ? Colors.white : AppColors.grey,
          ),
        ),
      ],
    );
  }
}

// --------------------------------------------------------------------------
// REUSE CUSTOM WIDGETS (Đã cập nhật theo phiên bản mới nhất của bạn)
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
    x = random.nextDouble();
    y = random.nextDouble();
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
            colors: [Color(0xFF6B4EEA), Color(0xFFE56BFA), Color(0xFF2E63FF)],
            stops: [0.1, 0.5, 0.9],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: const Color(0xFF6B4EEA).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Center(
          child: Text(widget.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 17)),
        ),
      ),
    );
  }
}
