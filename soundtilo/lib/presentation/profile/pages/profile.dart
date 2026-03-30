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
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
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

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leadingWidth: 56,
              titleSpacing: 8,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: _AppBarAvatar(
                    avatarUrl: avatarUrl,
                    username: username,
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 20),

                // Avatar with glow ring + edit overlay
                Center(
                  child: _ProfileAvatar(
                    avatarUrl: avatarUrl,
                    username: username,
                  ),
                ),

                const SizedBox(height: 16),

                // Name
                Text(
                  username,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],

                const SizedBox(height: 36),

                // Menu items
                _ProfileMenuCard(
                  icon: Icons.history_rounded,
                  title: 'Lịch sử nghe',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HistoryPage()),
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 12),
                  _ProfileMenuCard(
                    icon: Icons.manage_accounts_rounded,
                    title: 'Admin Users',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminUsersPage(),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                _ProfileMenuCard(
                  icon: Icons.dark_mode_rounded,
                  title: 'Giao diện',
                  subtitleWidget: BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, themeMode) {
                      final label = switch (themeMode) {
                        ThemeMode.dark => 'TỐI',
                        ThemeMode.light => 'SÁNG',
                        ThemeMode.system => 'HỆ THỐNG',
                      };
                      return Text(
                        label,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                  onTap: () => _showThemeDialog(context),
                ),
                const SizedBox(height: 12),
                _ProfileMenuCard(
                  icon: Icons.info_outline_rounded,
                  title: 'Thông tin ứng dụng',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Soundtilo',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2025 Soundtilo',
                  ),
                ),

                const SizedBox(height: 28),
                const SizedBox(height: 12),
                _ProfileMenuCard(
                  icon: Icons.manage_accounts_rounded,
                  title: 'Đổi mật khẩu & Thông tin',
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => _EditProfileDialog(
                      email: email,
                      currentName: username,
                      currentAvatar: avatarUrl,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // Logout button
                _LogoutButton(onTap: () => _showLogoutDialog(context)),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Private Widgets ───────────────────────────────────────────────────────────

class _AppBarAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String username;

  const _AppBarAvatar({required this.avatarUrl, required this.username});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
      child: avatarUrl != null && avatarUrl!.isNotEmpty
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: avatarUrl!,
                fit: BoxFit.cover,
                width: 36,
                height: 36,
                memCacheWidth: 72,
                memCacheHeight: 72,
                errorWidget: (_, __, ___) => _AvatarFallback(username: username, fontSize: 14),
                placeholder: (_, __) => const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 1.5),
                ),
              ),
            )
          : _AvatarFallback(username: username, fontSize: 14),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String username;

  const _ProfileAvatar({required this.avatarUrl, required this.username});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 116,
          height: 116,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: avatarUrl != null && avatarUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: avatarUrl!,
                    fit: BoxFit.cover,
                    width: 116,
                    height: 116,
                    memCacheWidth: 232,
                    memCacheHeight: 232,
                    errorWidget: (_, __, ___) =>
                        _AvatarFallbackLarge(username: username),
                    placeholder: (_, __) => const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : _AvatarFallbackLarge(username: username),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.edit,
              size: 16,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? subtitleWidget;
  final VoidCallback onTap;

  const _ProfileMenuCard({
    required this.icon,
    required this.title,
    this.subtitleWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    if (subtitleWidget != null) ...[
                      const SizedBox(height: 2),
                      subtitleWidget!,
                    ],
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.grey, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.errorColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, color: AppColors.errorColor, size: 20),
              const SizedBox(width: 10),
              Text(
                'Đăng xuất',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
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
  final double fontSize;

  const _AvatarFallback({required this.username, this.fontSize = 14});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        username.isNotEmpty ? username[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _AvatarFallbackLarge extends StatelessWidget {
  final String username;

  const _AvatarFallbackLarge({required this.username});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
// ─── Hộp thoại Đổi thông tin & Mật khẩu ──────────────────────────────────────

class _EditProfileDialog extends StatefulWidget {
  final String email;
  final String currentName;
  final String? currentAvatar;

  const _EditProfileDialog({
    required this.email,
    required this.currentName,
    this.currentAvatar,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _nameController;
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  Uint8List? _selectedImageBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  // Cắt chuỗi ẩn Email (Ví dụ: n***@gmail.com)
  String _getMaskedEmail(String email) {
    if (email.isEmpty || !email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.isEmpty) return email;
    return '${name[0]}***@$domain';
  }

  Future<String?> _uploadImageToImgBB(Uint8List imageBytes) async {
    const String apiKey = '19aa9239cea3d71680af0b6a6af6ef93';
    final url = Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey');

    try {
      final request = http.MultipartRequest('POST', url)
        ..files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'avatar.jpg',
        ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResult = json.decode(responseData);
        return jsonResult['data']['url'];
      } else {
        debugPrint('Lỗi upload ImgBB: Mã ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Lỗi kết nối ImgBB: $e');
    }
    return null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 60);

    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tên không được để trống!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? finalAvatarUrl = widget.currentAvatar;

      // 1. Nếu có chọn ảnh mới -> Tải lên ImgBB
      if (_selectedImageBytes != null) {
        final uploadedUrl = await _uploadImageToImgBB(_selectedImageBytes!);
        if (uploadedUrl != null) {
          finalAvatarUrl = uploadedUrl;
        } else {
          throw Exception('Không thể tải ảnh. Vui lòng thử lại.');
        }
      }

      // 2. GỌI BLoC / API ĐỂ LƯU VÀO BACKEND C# (.NET)
      // Anh/chị bắn Event vào AuthBloc (hoặc UserBloc) ở đây nhé. Ví dụ:

      context.read<AuthBloc>().add(AuthUpdateProfileRequested(
        displayName: _nameController.text.trim(),
        avatarUrl: finalAvatarUrl,
      ));

      if (_oldPasswordController.text.isNotEmpty && _newPasswordController.text.isNotEmpty) {
        context.read<AuthBloc>().add(AuthChangePasswordRequested(
          oldPassword: _oldPasswordController.text,
          newPassword: _newPasswordController.text,
        ));
      }


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
        Navigator.pop(context); // Đóng popup
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Hồ sơ của bạn', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 20),

            // Avatar Picker
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                      backgroundImage: _selectedImageBytes != null
                          ? MemoryImage(_selectedImageBytes!)
                          : (widget.currentAvatar != null ? CachedNetworkImageProvider(widget.currentAvatar!) : null) as ImageProvider?,
                      child: (_selectedImageBytes == null && widget.currentAvatar == null)
                          ? Text(widget.currentName[0].toUpperCase(), style: const TextStyle(fontSize: 40, color: AppColors.primary))
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Email (Chỉ đọc, đã làm mờ)
            TextField(
              controller: TextEditingController(text: _getMaskedEmail(widget.email)),
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),

            // Display Name
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên hiển thị',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(),
            ),
            const Text('Đổi mật khẩu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // Mật khẩu cũ
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu hiện tại (Để trống nếu không đổi)',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // Mật khẩu mới
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: const Icon(Icons.lock_reset),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            // Nút Lưu
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}