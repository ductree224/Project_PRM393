import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth < 600 ? 1 : (screenWidth < 1100 ? 2 : 4);
    bool isDesktop = screenWidth >= 1100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Console Dashboard',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE5E2E1),
            ),
          ),
          const SizedBox(height: 32),
          // Metric Cards
          GridView.count(
            crossAxisCount: crossAxisCount,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: screenWidth < 600 ? 2.5 : 1.5,
            children: [
              _buildMetricCard(
                icon: Icons.group,
                title: 'Total Users',
                value: '15,200',
                subtitle: 'Growth since last month',
                badgeText: '+12%',
                badgeColor: const Color(0xFF00D2FE),
              ),
              _buildMetricCard(
                icon: Icons.equalizer,
                title: 'Total Streams',
                value: '1.2M',
                subtitle: 'Global playback count',
                badgeText: '+8%',
                badgeColor: const Color(0xFF00D2FE),
              ),
              _buildMetricCard(
                icon: Icons.person_add,
                title: 'New Users Today',
                value: '250',
                subtitle: 'Verified registrations',
              ),
              _buildMetricCard(
                icon: Icons.folder_zip,
                title: 'Tracks in Cache',
                value: '45,800',
                subtitle: 'High-fidelity optimized',
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Charts Section
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _buildLineChart()),
                    const SizedBox(width: 24),
                    Expanded(flex: 1, child: _buildBarChart()),
                  ],
                )
              : Column(
                  children: [
                    _buildLineChart(),
                    const SizedBox(height: 24),
                    _buildBarChart(),
                  ],
                ),
          const SizedBox(height: 32),
          // Recent Activity Table
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05), height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      hoverColor: Colors.white.withOpacity(0.02),
                      leading: const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
                      title: const Text('Alex Mercer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: const Text('Admin Action: Track Approved', style: TextStyle(color: Colors.grey, fontSize: 10)),
                      trailing: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF00D2FE).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: const Text('VERIFIED', style: TextStyle(color: Color(0xFF00D2FE), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 16),
                          IconButton(icon: const Icon(Icons.more_vert, color: Colors.grey), onPressed: () {}),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 350,
      width: double.infinity,
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
                    Text('Lượt nghe 30 ngày qua', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Daily stream counts across all platforms', style: TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              Row(
                children: [
                  TextButton(onPressed: () {}, child: const Text('MONTHLY', style: TextStyle(color: Colors.grey, fontSize: 10))),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD79B), 
                      foregroundColor: const Color(0xFF432C00),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () {},
                    child: const Text('DAILY', style: TextStyle(fontSize: 12)),
                  )
                ],
              ),
            ],
          ),
          const Spacer(),
          const Center(child: Text('Chart Placeholder', style: TextStyle(color: Colors.white38))),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
      ),
      height: 350,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top 10 Tracks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Most played songs this week', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 24),
          _buildTopTrackRow('Neon Midnight - Arcane Echo', '42.5k', 0.95),
          const SizedBox(height: 16),
          _buildTopTrackRow('Silent Skyline - Luna V', '38.2k', 0.82),
          const SizedBox(height: 16),
          _buildTopTrackRow('Deep Bass Theory - Dr. Low', '31.8k', 0.70),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: const Color(0xFFFFD79B).withOpacity(0.2)),
                foregroundColor: const Color(0xFFFFD79B),
              ),
              child: const Text('VIEW FULL RANKING'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({required IconData icon, required String title, required String value, required String subtitle, String? badgeText, Color? badgeColor}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F), // surface-container
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.05)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor!.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopTrackRow(String name, String value, double percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: const Color(0xFF2A2A2A),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD79B)),
          borderRadius: BorderRadius.circular(4),
          minHeight: 6,
        ),
      ],
    );
  }
}
