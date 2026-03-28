import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:soundtilo/core/configs/assets/app_vectors.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';
import 'package:soundtilo/presentation/intro/pages/get_started.dart';
import 'package:soundtilo/presentation/main_shell.dart';
import 'package:soundtilo/presentation/admin/pages/admin_main_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasRedirected = false;

  @override
  void initState() {
    super.initState();
    _redirect();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.role == 'Admin') {
            _navigateToAdminShell();
          } else {
            _navigateToMainShell();
          }
        } else if (state is AuthUnauthenticated || state is AuthError) {
          _navigateToGetStarted();
        }
      },
      child: Scaffold(
        body: Center(
          child: SvgPicture.asset(AppVectors.logo),
        ),
      ),
    );
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      if (authState.user.role == 'Admin') {
        _navigateToAdminShell();
      } else {
        _navigateToMainShell();
      }
    } else if (authState is AuthUnauthenticated || authState is AuthError) {
      _navigateToGetStarted();
    }
  }

  void _navigateToMainShell() {
    if (!mounted || _hasRedirected) return;
    _hasRedirected = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  void _navigateToAdminShell() {
    if (!mounted || _hasRedirected) return;
    _hasRedirected = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AdminMainShell()),
    );
  }

  void _navigateToGetStarted() {
    if (!mounted || _hasRedirected) return;
    _hasRedirected = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GetStartedPage()),
    );
  }
}

