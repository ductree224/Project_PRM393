import 'package:flutter/material.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/admin_user_entity.dart';
import 'package:soundtilo/presentation/admin/pages/user_favorites_detail_page.dart';
import 'package:soundtilo/presentation/admin/pages/user_history_detail_page.dart';
import 'package:soundtilo/presentation/admin/pages/user_playlists_detail_page.dart';

class UserPlaylistDetailPage extends StatelessWidget {
  final AdminUserEntity user;

  const UserPlaylistDetailPage({super.key, required this.user});

  static Route<void> createRoute({required AdminUserEntity user}) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: '/admin/user-detail-hub'),
      builder: (_) => UserPlaylistDetailPage(user: user),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết người dùng')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayLabel,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(user.email),
                const SizedBox(height: 6),
                Text(
                  'Role: ${user.role} • ${user.isBanned ? 'Đã ban' : 'Hoạt động'}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _MenuTile(
            icon: Icons.history,
            title: 'Lịch sử nghe',
            subtitle: 'Xem chi tiết các lần nghe của user này',
            onTap: () => Navigator.push(
              context,
              UserHistoryDetailPage.createRoute(user: user),
            ),
          ),
          _MenuTile(
            icon: Icons.favorite_outline,
            title: 'Favorites',
            subtitle: 'Danh sách bài hát user đã thêm yêu thích',
            onTap: () => Navigator.push(
              context,
              UserFavoritesDetailPage.createRoute(user: user),
            ),
          ),
          _MenuTile(
            icon: Icons.queue_music,
            title: 'Playlists',
            subtitle: 'Danh sách playlists user đã tạo',
            onTap: () => Navigator.push(
              context,
              UserPlaylistsDetailPage.createRoute(user: user),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
