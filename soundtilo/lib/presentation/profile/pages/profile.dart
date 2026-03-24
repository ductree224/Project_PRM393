import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundtilo/common/helper/jwt_helper.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/presentation/admin/pages/users_page.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_event.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';
import 'package:soundtilo/presentation/choose_mode/bloc/theme_cubit.dart';
import 'package:soundtilo/presentation/history/pages/history.dart';
import 'package:soundtilo/presentation/intro/pages/get_started.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _showThemeDialog(BuildContext context) {
    final themeCubit = context.read<ThemeCubit>();
    showDialog(
      context: context,
      builder: (ctx) {
        return BlocProvider.value(
          value: themeCubit,
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            bloc: themeCubit,
            builder: (context, currentMode) {
              return AlertDialog(
                title: const Text('Chọn giao diện'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ThemeOption(
                      icon: Icons.light_mode,
                      title: 'Sáng',
                      isSelected: currentMode == ThemeMode.light,
                      onTap: () {
                        themeCubit.updateTheme(ThemeMode.light);
                        Navigator.pop(ctx);
                      },
                    ),
                    _ThemeOption(
                      icon: Icons.dark_mode,
                      title: 'Tối',
                      isSelected: currentMode == ThemeMode.dark,
                      onTap: () {
                        themeCubit.updateTheme(ThemeMode.dark);
                        Navigator.pop(ctx);
                      },
                    ),
                    _ThemeOption(
                      icon: Icons.settings_suggest,
                      title: 'Theo hệ thống',
                      isSelected: currentMode == ThemeMode.system,
                      onTap: () {
                        themeCubit.updateTheme(ThemeMode.system);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const GetStartedPage()),
                (route) => false,
              );
            }
          },
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String username = 'Người dùng';
              String email = '';
              String? avatarUrl;
              final token = sl<SharedPreferences>().getString('access_token');
              final isAdmin = JwtHelper.isAdmin(token);

              if (state is AuthAuthenticated) {
                username = state.user.displayName ?? state.user.username;
                email = state.user.email;
                avatarUrl = state.user.avatarUrl;
              }

              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 20),

                  // Avatar
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: avatarUrl,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                memCacheWidth: 200,
                                memCacheHeight: 200,
                                errorWidget: (context, url, error) =>
                                    _AvatarFallback(username: username),
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : _AvatarFallback(username: username),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Name
                  Text(
                    username,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        email,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.grey),
                      ),
                    ),

                  const SizedBox(height: 40),

                  // Menu items
                  _MenuItem(
                    icon: Icons.history,
                    title: 'Lịch sử nghe',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryPage()),
                      );
                    },
                  ),
                  if (isAdmin)
                    _MenuItem(
                      icon: Icons.manage_accounts,
                      title: 'Admin Users',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminUsersPage(),
                          ),
                        );
                      },
                    ),
                  _MenuItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Giao diện',
                    trailing: BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, themeMode) {
                        String label;
                        switch (themeMode) {
                          case ThemeMode.dark:
                            label = 'Tối';
                            break;
                          case ThemeMode.light:
                            label = 'Sáng';
                            break;
                          case ThemeMode.system:
                            label = 'Hệ thống';
                        }
                        return Text(
                          label,
                          style: TextStyle(color: AppColors.grey),
                        );
                      },
                    ),
                    onTap: () {
                      _showThemeDialog(context);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.info_outline,
                    title: 'Thông tin ứng dụng',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Soundtilo',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2025 Soundtilo',
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Logout
                  TextButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Đăng xuất'),
                          content: const Text(
                            'Bạn có chắc chắn muốn đăng xuất?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Huỷ'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                context.read<AuthBloc>().add(
                                  AuthLogoutRequested(),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorColor,
                              ),
                              child: const Text('Đăng xuất'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout, color: AppColors.errorColor),
                    label: const Text(
                      'Đăng xuất',
                      style: TextStyle(
                        color: AppColors.errorColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final String username;

  const _AvatarFallback({required this.username});

  @override
  Widget build(BuildContext context) {
    return Text(
      username.isNotEmpty ? username[0].toUpperCase() : '?',
      style: const TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}
