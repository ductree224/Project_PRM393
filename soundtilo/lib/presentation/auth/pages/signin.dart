import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_event.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';
import 'package:soundtilo/presentation/auth/pages/forgot_password.dart';
import 'package:soundtilo/presentation/auth/pages/signup.dart';
import 'package:soundtilo/presentation/main_shell.dart';
import 'package:soundtilo/presentation/admin/pages/admin_main_shell.dart';

import '../../../common/widgets/textFormField/custom_field.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  static const _rememberMeKey = 'remember_me';
  static const _rememberedEmailKey = 'remembered_email';

  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _loadRememberMe() {
    final prefs = sl<SharedPreferences>();
    final isRemembered = prefs.getBool(_rememberMeKey) ?? false;
    final rememberedEmail = prefs.getString(_rememberedEmailKey);
    if (!mounted) return;
    setState(() {
      rememberMe = isRemembered;
      if (isRemembered &&
          rememberedEmail != null &&
          rememberedEmail.isNotEmpty) {
        nameController.text = rememberedEmail;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.role == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AdminMainShell()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainShell()),
              (route) => false,
            );
          }
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
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
          ),
          title: SvgPicture.asset(AppVectors.logo, height: 40),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Positioned.fill(child: _SoundParticlesWidget()),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 20,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _DelayedWidget(
                        delay: const Duration(milliseconds: 100),
                        child: Text(
                          'Chào mừng trở lại',
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
                          'Đăng nhập để tiếp tục trải nghiệm âm nhạc',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                children: [
                                  CustomField(
                                    labelText: 'Tên đăng nhập hoặc email',
                                    controller: nameController,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomField(
                                    labelText: 'Mật khẩu',
                                    controller: passwordController,
                                    isObscureText: true,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: rememberMe,
                                          activeColor: AppColors.primary,
                                          side: BorderSide(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                          ),
                                          onChanged: (value) => setState(
                                            () => rememberMe = value ?? false,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ghi nhớ tôi',
                                        style: GoogleFonts.inter(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const ForgotPasswordPage(),
                                          ),
                                        ),
                                        child: Text(
                                          'Quên mật khẩu?',
                                          style: GoogleFonts.inter(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _DelayedWidget(
                        delay: const Duration(milliseconds: 400),
                        child: BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              );
                            }
                            return _BasicGradientAppButton(
                              onPressed: _onSignIn,
                              title: 'Đăng nhập',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),
                      _DelayedWidget(
                        delay: const Duration(milliseconds: 500),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: Text(
                                'hoặc',
                                style: GoogleFonts.inter(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      _DelayedWidget(
                        delay: const Duration(milliseconds: 600),
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: OutlinedButton.icon(
                            onPressed: () => context.read<AuthBloc>().add(
                              AuthGoogleSignInRequested(),
                            ),
                            icon: SvgPicture.asset(
                              AppVectors.google,
                              width: 22,
                            ),
                            label: Text(
                              'Tiếp tục với Google',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _DelayedWidget(
                        delay: const Duration(milliseconds: 700),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Bạn chưa có tài khoản?',
                              style: GoogleFonts.inter(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignUpPage(),
                                ),
                              ),
                              child: Text(
                                'Đăng ký ngay',
                                style: GoogleFonts.inter(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
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

  void _onSignIn() {
    if (formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          usernameOrEmail: nameController.text.trim(),
          password: passwordController.text,
          rememberMe: rememberMe,
        ),
      );
    }
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
}

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
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _show = true);
    });
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

class _SoundParticlesWidgetState extends State<_SoundParticlesWidget>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    final random = math.Random();
    for (int i = 0; i < 70; i++) {
      _particles.add(_Particle(random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          CustomPaint(painter: _ParticlePainter(_particles, _controller.value)),
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
    x += velocityX;
    y += velocityY;
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
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    for (final p in particles) {
      p.update();
      paint.color = Colors.white.withOpacity(p.opacity);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
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
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_scale),
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.thirdly, AppColors.primary, AppColors.secondary],
            stops: [0.0, 0.5, 1.0],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }

  String get title => widget.title;
}
