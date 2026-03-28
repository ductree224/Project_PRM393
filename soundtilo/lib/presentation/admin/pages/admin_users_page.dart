import 'package:flutter/material.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >= 1100;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('User Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text("Review, monitor, and manage the platform's architectural members.", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              if (isDesktop) 
                Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF353534), foregroundColor: const Color(0xFFFFD79B)),
                      onPressed: () {},
                      child: const Text('All Users'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(onPressed: () {}, child: const Text('Premium', style: TextStyle(color: Colors.grey))),
                    TextButton(onPressed: () {}, child: const Text('Artists', style: TextStyle(color: Colors.grey))),
                  ],
                )
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: isDesktop 
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Table
                      Expanded(
                        flex: 2,
                        child: _buildTableContainer(),
                      ),
                      const SizedBox(width: 24),
                      // Side Panel
                      Expanded(
                        flex: 1,
                        child: _buildSidePanelContainer(),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 400, child: _buildTableContainer()),
                        const SizedBox(height: 24),
                        SizedBox(height: 600, child: _buildSidePanelContainer()),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableContainer() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 30, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tools
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildDropdown('Filter by Role', 'All Roles'),
                      const SizedBox(width: 16),
                      _buildDropdown('Status', 'Any Status'),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.filter_list, color: Colors.grey, size: 16),
                    label: const Text('Advanced Filters', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  )
                ],
              ),
            ),
          ),
          // Data Table
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(const Color(0xFF2A2A2A).withOpacity(0.5)),
                  columns: const [
                    DataColumn(label: Text('NAME', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ROLE', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('STATUS', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('JOIN DATE', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('ACTIONS', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold))),
                  ],
                  rows: [
                    _buildUserRow('Elena Vance', 'elena.v@audioflow.com', 'Standard User', const Color(0xFFEAC07D), 'Active', Colors.greenAccent, 'Oct 12, 2023'),
                    _buildUserRow('Marcus Sterling', 'm.sterling@sonic.io', 'Administrator', const Color(0xFFFFD79B), 'Active', Colors.greenAccent, 'Sep 04, 2023'),
                    _buildUserRow('Julian Thorne', 'jthorne@musicbox.net', 'Artist', const Color(0xFFA4E7FF), 'Banned', Colors.redAccent, 'Jan 15, 2024'),
                    _buildUserRow('Sasha Bloom', 'sbloom@studio.com', 'Standard User', const Color(0xFFEAC07D), 'Active', Colors.greenAccent, 'Dec 22, 2023'),
                    _buildUserRow('Liam Rivera', 'liam_riv@gmail.com', 'Standard User', const Color(0xFFEAC07D), 'Active', Colors.greenAccent, 'Feb 01, 2024'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanelContainer() {
    return Column(
      children: [
        // Stats
        Row(
          children: [
            Expanded(child: _buildMiniStat('Total Active', '1,120', '12% increase', const Color(0xFFFFD79B), Icons.trending_up)),
            const SizedBox(width: 16),
            Expanded(child: _buildMiniStat('Banned', '42', 'Action Required', Colors.redAccent, Icons.warning)),
          ],
        ),
        const SizedBox(height: 24),
        // Detail Panel
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Julian Thorne', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Artist', style: TextStyle(color: Color(0xFFA4E7FF), fontSize: 14)),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD79B), foregroundColor: Colors.black),
                        onPressed: () {},
                        child: const Text('Unban User'),
                      ),
                      TextButton(onPressed: () {}, child: const Text('Edit Profile', style: TextStyle(color: Colors.white))),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Align(alignment: Alignment.centerLeft, child: Text('ACTIVITY OVERVIEW', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold))),
                  const Divider(color: Colors.white10, height: 24),
                  // ... other details omitted for brevity
                  const SizedBox(height: 100), // Filler
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    label: const Text('Permanently Delete User', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(width: 24),
              const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 20),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildMiniStat(String title, String value, String sub, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(sub, style: TextStyle(color: color, fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  DataRow _buildUserRow(String name, String email, String role, Color roleColor, String status, Color statusColor, String date) {
    return DataRow(
      cells: [
        DataCell(Row(
          children: [
            const CircleAvatar(radius: 16, backgroundColor: Color(0xFF353534)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(email, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        )),
        DataCell(Text(role, style: TextStyle(color: roleColor, fontWeight: FontWeight.bold))),
        DataCell(Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 3, backgroundColor: statusColor),
            const SizedBox(width: 8),
            Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
          ],
        )),
        DataCell(Text(date, style: const TextStyle(color: Colors.grey))),
        DataCell(IconButton(icon: const Icon(Icons.more_vert, color: Colors.grey), onPressed: () {})),
      ],
    );
  }
}
