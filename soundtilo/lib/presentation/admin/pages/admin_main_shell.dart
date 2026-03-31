import 'package:flutter/material.dart';

import 'package:soundtilo/presentation/admin/widgets/admin_sidebar.dart';
import 'package:soundtilo/presentation/admin/widgets/admin_topbar.dart';

import 'admin_dashboard_page.dart';
import 'users_page.dart';
import 'admin_analytics_page.dart';
import 'admin_tracks_page.dart';
import 'admin_artists_albums_page.dart';
import 'admin_notifications_page.dart';
import 'admin_subscriptions_page.dart';

class AdminMainShell extends StatefulWidget {
  const AdminMainShell({super.key});

  @override
  State<AdminMainShell> createState() => _AdminMainShellState();
}

class _AdminMainShellState extends State<AdminMainShell> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminDashboardPage(),
    const AdminTracksPage(), // Index 1: Track Mgt
    const AdminArtistsAlbumsPage(), // Index 2
    const AdminUsersPage(), // Index 3: User Mgt
    const AdminNotificationsPage(), // Index 4: Notifications
    const AdminAnalyticsPage(), // Index 5: Analytics
    const AdminSubscriptionsPage(), // Index 6: Payment Management
  ];

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFF131313), // background color
      appBar: isDesktop
          ? null
          : AppBar(
              title: const Text(
                'Admin Console',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF131313),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
      drawer: isDesktop
          ? Drawer(
              backgroundColor: const Color(0xFF0E0E0E),
              child: AdminSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  Navigator.pop(context); // Close drawer
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (isDesktop)
            AdminSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) const AdminTopBar(),
                Expanded(
                  child: IndexedStack(index: _selectedIndex, children: _pages),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
