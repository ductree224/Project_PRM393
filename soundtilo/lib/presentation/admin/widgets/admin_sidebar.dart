import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_event.dart';

class AdminSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AdminSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <_SidebarEntry>[
      const _SidebarEntry(icon: Icons.dashboard, label: 'Dashboard', index: 0),
      const _SidebarEntry(
        icon: Icons.music_note,
        label: 'Track Management',
        index: 1,
      ),
      const _SidebarEntry(icon: Icons.album, label: 'Artist & Album', index: 2),
      const _SidebarEntry(
        icon: Icons.people,
        label: 'User Management',
        index: 3,
      ),
      const _SidebarEntry(
        icon: Icons.notifications_active,
        label: 'Notification Management',
        index: 4,
      ),
      const _SidebarEntry(icon: Icons.insights, label: 'Analytics', index: 5),
      const _SidebarEntry(
        icon: Icons.payment,
        label: 'Payment Management',
        index: 6,
      ),
      const _SidebarEntry(
        icon: Icons.feedback,
        label: 'Feedback',
        index: 7,
      ),
    ];

    return Container(
      width: 256,
      color: const Color(0xFF0E0E0E),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Header
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Row(
              children: [
                Icon(Icons.graphic_eq, color: Color(0xFFFFD79B), size: 32),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sonic Architect',
                      style: TextStyle(
                        color: Color(0xFFE5E2E1),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'STUDIO CONSOLE',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Navigation Links
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: entries
                  .map(
                    (entry) => _NavItem(
                      icon: entry.icon,
                      label: entry.label,
                      isSelected: selectedIndex == entry.index,
                      onTap: () => onItemSelected(entry.index),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          const Divider(color: Colors.white10, height: 1, thickness: 1),
          _NavItem(
            icon: Icons.logout,
            label: 'Logout',
            isSelected: false,
            onTap: () {
              // Trigger AuthLogoutRequested
              context.read<AuthBloc>().add(AuthLogoutRequested());

              // Optional: Show a confirmation dialog or just logout
              // For now, making it direct as per most dashboard patterns
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SidebarEntry {
  final IconData icon;
  final String label;
  final int index;

  const _SidebarEntry({
    required this.icon,
    required this.label,
    required this.index,
  });
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isSelected ? const Color(0xFFEAC07D) : Colors.transparent,
              width: 4,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFFFD79B)
                  : const Color(0xFFD6C4AC).withValues(alpha: 0.7),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFFFD79B)
                    : const Color(0xFFD6C4AC).withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
