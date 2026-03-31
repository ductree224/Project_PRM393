import 'package:flutter/material.dart';

class AdminTopBar extends StatelessWidget {
  const AdminTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF131313).withOpacity(0.8),
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          // Search Bar
          Expanded(
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: const Color(0xFFD6C4AC).withOpacity(0.5), size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search streams, tracks, or artists...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: EdgeInsets.only(bottom: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Icons (Removed as requested)
          const SizedBox(width: 12),
          Container(width: 1, height: 32, color: Colors.white.withOpacity(0.1)),
          const SizedBox(width: 12),
          // User Profile
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Admin Console',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                'Super Admin',
                style: TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD79B).withOpacity(0.2), width: 2),
            ),
            child: const CircleAvatar(
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=68'),
            ),
          ),
        ],
      ),
    );
  }
}
