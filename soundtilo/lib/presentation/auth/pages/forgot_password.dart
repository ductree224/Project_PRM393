import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_event.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';
import 'package:soundtilo/presentation/auth/pages/reset_password.dart';
import '../../../common/widgets/textFormField/custom_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthForgotPasswordSuccess) {
          _showSuccessSnackBar(context, 'Yêu cầu đặt lại mật khẩu thành công.');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ResetPasswordPage(initialToken: state.token),
            ),
          );
        } else if (state is AuthError) {
          _showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          ),
          title: SvgPicture.asset(AppVectors.logo, height: 40),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            // 1. NỀN ĐỘNG (Đồng bộ)
            Positioned.fill(child: _SoundParticlesWidget()),
            
            // 2. LỚP PHỦ GRADIENT
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.9)],
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // 3. TIÊU ĐỀ
                      _DelayedWidget(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Quên mật khẩu',
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _DelayedWidget(
                        delay: const Duration(milliseconds: 200),
                        child: Text(
                          'Nhập email để nhận mã đặt lại mật khẩu của bạn',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // 4. FORM CARD (Glassmorphism)
                      _DelayedWidget(
                        delay: const Duration(milliseconds: 300),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: CustomField(
                                labelText: 'Email',
                                controller: _emailController,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // 5. NÚT GỬI YÊU CẦU
                      _DelayedWidget(
                        delay: const Duration(milliseconds: 400),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                            }
                            return _BasicGradientAppButton(
                              onPressed: _submit,
                              title: 'Gửi yêu cầu',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<AuthBloc>().add(
          AuthForgotPasswordRequested(
            email: _emailController.text.trim(),
          ),
        );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
