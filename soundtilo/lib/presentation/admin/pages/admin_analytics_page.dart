import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/usecases/admin_analytics_usecases.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_analytics_bloc.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_analytics_event.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_analytics_state.dart';

class AdminAnalyticsPage extends StatelessWidget {
  const AdminAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminAnalyticsBloc(
        getOverview: sl<GetAnalyticsOverviewUseCase>(),
        getTopTracks: sl<GetAnalyticsTopTracksUseCase>(),
        getDailyStats: sl<GetAnalyticsDailyStatsUseCase>(),
        getSubscriptionStats: sl<GetAdminSubscriptionStatsUseCase>(),
      )..add(const AdminAnalyticsStarted()),
      child: const _AnalyticsBody(),
    );
  }
}

class _AnalyticsBody extends StatefulWidget {
  const _AnalyticsBody();

  @override
  State<_AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<_AnalyticsBody> {
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    _toDate = DateTime.now();
    _fromDate = _toDate.subtract(const Duration(days: 29));
  }

  String _fmt(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFFFFD79B),
            onPrimary: Colors.black,
            surface: const Color(0xFF201F1F),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      if (isFrom) _fromDate = picked; else _toDate = picked;
    });
    if (!mounted) return;
    context.read<AdminAnalyticsBloc>().add(AdminAnalyticsDateRangeChanged(from: _fmt(_fromDate), to: _fmt(_toDate)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminAnalyticsBloc, AdminAnalyticsState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE5E2E1))),
                  Row(
                    children: [
                      _DatePickerButton(label: 'Từ', date: _fromDate, onTap: () => _pickDate(true)),
                      const SizedBox(width: 8),
                      const Text('→', style: TextStyle(color: Colors.grey)),
                      const SizedBox(width: 8),
                      _DatePickerButton(label: 'Đến', date: _toDate, onTap: () => _pickDate(false)),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => context.read<AdminAnalyticsBloc>().add(const AdminAnalyticsRefresh()),
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (state.status == AdminAnalyticsStatus.error && state.errorMessage != null)
                _ErrorBanner(message: state.errorMessage!),

              // Overview grid
              const _SectionHeader(title: 'Tổng quan hệ thống', subtitle: 'Số liệu tổng thể toàn hệ thống'),
              const SizedBox(height: 16),
              _OverviewGrid(state: state),
              const SizedBox(height: 32),

              // Subscription Revenue section
              const _SectionHeader(title: 'Doanh thu từ Subscription', subtitle: 'Báo cáo Premium / VNPay'),
              const SizedBox(height: 16),
              _SubscriptionRevenueCard(state: state),
              const SizedBox(height: 32),

              // Listening time
              const _SectionHeader(title: 'Thời gian nghe nhạc', subtitle: 'Tổng thời gian streaming'),
              const SizedBox(height: 16),
              _ListeningTimeCard(state: state),
              const SizedBox(height: 32),

              // Top Tracks
              const _SectionHeader(title: 'Top Tracks', subtitle: 'Bài hát được nghe nhiều nhất'),
              const SizedBox(height: 16),
              _TopTracksTable(state: state),
              const SizedBox(height: 32),

              // Daily Stats
              const _SectionHeader(title: 'Thống kê theo ngày', subtitle: 'Dữ liệu trong khoảng thời gian đã chọn'),
              const SizedBox(height: 16),
              _DailyStatsTable(state: state),
            ],
          ),
        );
      },
    );
  }
}

// ─── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

// ─── Date Picker Button ────────────────────────────────────────────────────────

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  const _DatePickerButton({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Text(
          '$label  ${DateFormat('dd/MM/yyyy').format(date)}',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }
}

// ─── Error Banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.redAccent, fontSize: 13))),
        ],
      ),
    );
  }
}

// ─── Overview Grid ─────────────────────────────────────────────────────────────

class _OverviewGrid extends StatelessWidget {
  final AdminAnalyticsState state;
  const _OverviewGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AdminAnalyticsStatus.loading;
    final o = state.overview;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossCount = screenWidth < 600 ? 2 : (screenWidth < 1100 ? 3 : 6);

    final items = [
      ('Total Users', o?.totalUsers, Icons.group, null),
      ('Banned Users', o?.totalBannedUsers, Icons.block, Colors.redAccent),
      ('Admins', o?.totalAdmins, Icons.admin_panel_settings, const Color(0xFFFFD79B)),
      ('New (7 days)', o?.newUsersLast7Days, Icons.person_add, Colors.greenAccent),
      ('Total Tracks', o?.totalTracks, Icons.music_note, Colors.blueAccent),
      ('Playlists', o?.totalPlaylists, Icons.queue_music, Colors.purpleAccent),
    ];

    return GridView.count(
      crossAxisCount: crossCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: items.map((item) {
        final (title, value, icon, color) = item;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color ?? Colors.grey, size: 22),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isLoading || value == null)
                    Container(height: 28, width: 70, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(4)))
                  else
                    Text(NumberFormat('#,###').format(value), style: TextStyle(color: color ?? Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ─── Subscription Revenue ──────────────────────────────────────────────────────

class _SubscriptionRevenueCard extends StatelessWidget {
  final AdminAnalyticsState state;
  const _SubscriptionRevenueCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AdminAnalyticsStatus.loading;
    final s = state.subscriptionStats;
    final arpu = (s != null && s.activeSubscriptions > 0) ? s.totalRevenue / s.activeSubscriptions : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1F00), Color(0xFF1E1B12)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFFFD79B).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.monetization_on, color: Color(0xFFFFD79B), size: 22),
              SizedBox(width: 8),
              Text('Doanh thu Premium', style: TextStyle(color: Color(0xFFFFD79B), fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            final tiles = [
              _RevenueTile(
                label: 'Tổng doanh thu',
                value: isLoading || s == null ? null : NumberFormat('#,###').format(s.totalRevenue.toInt()),
                unit: '₫',
                color: const Color(0xFFFFD79B),
                large: true,
              ),
              _RevenueTile(
                label: 'Subscriptions đang hoạt động',
                value: isLoading || s == null ? null : NumberFormat('#,###').format(s.activeSubscriptions),
                unit: '',
                color: Colors.greenAccent,
              ),
              _RevenueTile(
                label: 'Người dùng Premium',
                value: isLoading || s == null ? null : NumberFormat('#,###').format(s.totalPremiumUsers),
                unit: '',
                color: Colors.cyanAccent,
              ),
              _RevenueTile(
                label: 'Người dùng Free',
                value: isLoading || s == null ? null : NumberFormat('#,###').format(s.totalFreeUsers),
                unit: '',
                color: Colors.blueGrey,
              ),
              _RevenueTile(
                label: 'ARPU (Bình quân/sub)',
                value: isLoading || s == null ? null : NumberFormat('#,###').format(arpu.toInt()),
                unit: '₫',
                color: Colors.orangeAccent,
              ),
            ];
            if (isWide) {
              return Wrap(spacing: 24, runSpacing: 16, children: tiles);
            }
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: tiles.map((t) => Padding(padding: const EdgeInsets.only(bottom: 16), child: t)).toList());
          }),
        ],
      ),
    );
  }
}

class _RevenueTile extends StatelessWidget {
  final String label;
  final String? value;
  final String unit;
  final Color color;
  final bool large;
  const _RevenueTile({required this.label, required this.value, required this.unit, required this.color, this.large = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (value == null)
          Container(height: large ? 40 : 28, width: large ? 160 : 90, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(6)))
        else
          Text('$value $unit'.trim(), style: TextStyle(color: color, fontSize: large ? 36 : 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Listening Time Card ───────────────────────────────────────────────────────

class _ListeningTimeCard extends StatelessWidget {
  final AdminAnalyticsState state;
  const _ListeningTimeCard({required this.state});

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours >= 1000) return '${NumberFormat('#,###').format(hours)} giờ';
    return '${NumberFormat('#,###').format(hours)}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AdminAnalyticsStatus.loading;
    final totalSec = state.overview?.totalListeningTimeSeconds ?? 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.headphones, color: Colors.blueAccent, size: 32),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading)
                Container(height: 40, width: 200, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(6)))
              else
                Text(_formatTime(totalSec), style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Tổng thời gian nghe nhạc (all-time)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Top Tracks Table ──────────────────────────────────────────────────────────

class _TopTracksTable extends StatelessWidget {
  final AdminAnalyticsState state;
  const _TopTracksTable({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AdminAnalyticsStatus.loading;
    final tracks = state.topTracks;

    return Container(
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (isLoading)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Color(0xFFFFD79B), strokeWidth: 2)))
          else if (tracks.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey))))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF2A2929)),
                dataRowColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? const Color(0xFF2A2929) : Colors.transparent),
                dividerThickness: 0.3,
                columns: const [
                  DataColumn(label: Text('#', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Title', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Artist', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Play Count', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), numeric: true),
                ],
                rows: tracks.asMap().entries.map((entry) {
                  final i = entry.key;
                  final t = entry.value;
                  return DataRow(
                    cells: [
                      DataCell(Container(
                        width: 28, height: 28,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: i < 3 ? const Color(0xFFFFD79B).withOpacity(0.15) : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Text('${i + 1}', style: TextStyle(color: i < 3 ? const Color(0xFFFFD79B) : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                      )),
                      DataCell(ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 240),
                        child: Text(t.title, style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
                      )),
                      DataCell(ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(t.artist, style: const TextStyle(color: Colors.grey, fontSize: 13), overflow: TextOverflow.ellipsis),
                      )),
                      DataCell(Text(NumberFormat('#,###').format(t.playCount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Daily Stats Table ─────────────────────────────────────────────────────────

class _DailyStatsTable extends StatelessWidget {
  final AdminAnalyticsState state;
  const _DailyStatsTable({required this.state});

  String _formatHours(int sec) {
    final h = sec ~/ 3600;
    final m = (sec % 3600) ~/ 60;
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AdminAnalyticsStatus.loading;
    final stats = state.dailyStats;

    return Container(
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (isLoading)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: Color(0xFFFFD79B), strokeWidth: 2)))
          else if (stats.isEmpty)
            const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey))))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(const Color(0xFF2A2929)),
                dataRowColor: WidgetStateProperty.resolveWith((_) => Colors.transparent),
                dividerThickness: 0.3,
                columns: const [
                  DataColumn(label: Text('Ngày', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Người mới', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Tổng lượt nghe', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), numeric: true),
                  DataColumn(label: Text('Thời gian nghe', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))),
                ],
                rows: stats.map((s) {
                  return DataRow(
                    cells: [
                      DataCell(Text(s.date.length >= 10 ? s.date.substring(0, 10) : s.date, style: const TextStyle(color: Colors.white, fontSize: 13))),
                      DataCell(Text(NumberFormat('#,###').format(s.newUsers), style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13))),
                      DataCell(Text(NumberFormat('#,###').format(s.totalListens), style: const TextStyle(color: Colors.white, fontSize: 13))),
                      DataCell(Text(_formatHours(s.totalListeningTimeSeconds), style: const TextStyle(color: Colors.cyanAccent, fontSize: 13))),
                    ],
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
