import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/entities/admin_dashboard_entity.dart';
import 'package:soundtilo/domain/usecases/admin_dashboard_usecases.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_dashboard_bloc.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_dashboard_event.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_dashboard_state.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminDashboardBloc(
        getSummary: sl<GetDashboardSummaryUseCase>(),
        getPlayTrend: sl<GetDashboardPlayTrendUseCase>(),
        getUserGrowth: sl<GetDashboardUserGrowthUseCase>(),
        getTopTracks: sl<GetDashboardTopTracksUseCase>(),
      )..add(const AdminDashboardStarted()),
      child: const _DashboardBody(),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  List<String> _recentMonths() {
    final now = DateTime.now();
    return List.generate(12, (i) {
      final d = DateTime(now.year, now.month - i, 1);
      return '${d.year}-${d.month.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 1 : (screenWidth < 1100 ? 2 : 4);
    final isDesktop = screenWidth >= 1100;
    final months = _recentMonths();

    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
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
                  const Text(
                    'Console Dashboard',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFFE5E2E1)),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF201F1F),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: state.selectedMonth,
                            dropdownColor: const Color(0xFF201F1F),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            hint: const Text('Tháng hiện tại', style: TextStyle(color: Colors.grey, fontSize: 13)),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('Tháng hiện tại', style: TextStyle(color: Colors.grey)),
                              ),
                              ...months.map((m) => DropdownMenuItem<String?>(value: m, child: Text(m))),
                            ],
                            onChanged: (value) => context.read<AdminDashboardBloc>().add(AdminDashboardMonthChanged(value)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => context.read<AdminDashboardBloc>().add(const AdminDashboardRefresh()),
                        icon: const Icon(Icons.refresh, color: Colors.grey),
                        tooltip: 'Làm mới',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              if (state.status == AdminDashboardStatus.error && state.errorMessage != null)
                _ErrorBanner(message: state.errorMessage!),

              GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: screenWidth < 600 ? 2.5 : 1.5,
                children: [
                  _MetricCard(
                    icon: Icons.group,
                    title: 'Total Users',
                    value: state.status == AdminDashboardStatus.loading ? null : _fmt(state.summary?.totalUsers ?? 0),
                    subtitle: 'Tổng số người dùng',
                  ),
                  _MetricCard(
                    icon: Icons.equalizer,
                    title: 'Total Streams',
                    value: state.status == AdminDashboardStatus.loading ? null : _fmt(state.summary?.totalPlayCount ?? 0),
                    subtitle: 'Tổng lượt nghe (all-time)',
                  ),
                  _MetricCard(
                    icon: Icons.person_add,
                    title: 'New Users Today',
                    value: state.status == AdminDashboardStatus.loading ? null : NumberFormat('#,###').format(state.summary?.newUsersToday ?? 0),
                    subtitle: 'Đăng ký mới hôm nay',
                  ),
                  _MetricCard(
                    icon: Icons.folder_zip,
                    title: 'Tracks in Cache',
                    value: state.status == AdminDashboardStatus.loading ? null : _fmt(state.summary?.cachedTracks ?? 0),
                    subtitle: 'Cache hiện đang hoạt động',
                  ),
                ],
              ),
              const SizedBox(height: 32),

              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _PlayTrendChart(chart: state.playTrend, isLoading: state.status == AdminDashboardStatus.loading)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _TopTracksBar(topTracks: state.topTracks, isLoading: state.status == AdminDashboardStatus.loading)),
                      ],
                    )
                  : Column(
                      children: [
                        _PlayTrendChart(chart: state.playTrend, isLoading: state.status == AdminDashboardStatus.loading),
                        const SizedBox(height: 24),
                        _TopTracksBar(topTracks: state.topTracks, isLoading: state.status == AdminDashboardStatus.loading),
                      ],
                    ),
              const SizedBox(height: 32),
              _UserGrowthChart(chart: state.userGrowth, isLoading: state.status == AdminDashboardStatus.loading),
            ],
          ),
        );
      },
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

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

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final String subtitle;
  final String? badgeText;
  final Color? badgeColor;

  const _MetricCard({required this.icon, required this.title, required this.value, required this.subtitle, this.badgeText, this.badgeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Positioned(right: -20, bottom: -20, child: Icon(icon, size: 80, color: Colors.white.withOpacity(0.05))),
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
                      decoration: BoxDecoration(color: badgeColor!.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(badgeText!, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (value == null)
                    Container(height: 36, width: 100, decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(6)))
                  else
                    Text(value!, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayTrendChart extends StatelessWidget {
  final AdminDashboardChartEntity? chart;
  final bool isLoading;
  const _PlayTrendChart({required this.chart, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final points = chart?.points ?? [];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      height: 350,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lượt nghe theo ngày', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Play count hàng ngày', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD79B), strokeWidth: 2))
                : points.isEmpty
                    ? const Center(child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)))
                    : CustomPaint(painter: _LineChartPainter(points: points), child: const SizedBox.expand()),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<AdminDashboardDailyPointEntity> points;
  const _LineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final maxVal = points.map((p) => p.value).reduce(math.max).toDouble().clamp(1.0, double.infinity);
    final minVal = points.map((p) => p.value).reduce(math.min).toDouble();
    final range = (maxVal - minVal).clamp(1.0, double.infinity);
    const pT = 10.0; const pB = 24.0; const pH = 8.0;
    final cW = size.width - pH * 2; final cH = size.height - pT - pB;

    Offset toOff(int i, int v) => Offset(pH + (i / (points.length - 1)) * cW, pT + (1 - (v - minVal) / range) * cH);

    final gridPaint = Paint()..color = Colors.white.withOpacity(0.06)..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = pT + (i / 4) * cH;
      canvas.drawLine(Offset(pH, y), Offset(size.width - pH, y), gridPaint);
    }

    final fillPath = Path()..moveTo(pH, size.height - pB);
    for (int i = 0; i < points.length; i++) { fillPath.lineTo(toOff(i, points[i].value).dx, toOff(i, points[i].value).dy); }
    fillPath.lineTo(size.width - pH, size.height - pB); fillPath.close();
    canvas.drawPath(fillPath, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [const Color(0xFFFFD79B).withOpacity(0.25), const Color(0xFFFFD79B).withOpacity(0.0)],
    ).createShader(Rect.fromLTWH(0, pT, size.width, cH)));

    final linePath = Path();
    for (int i = 0; i < points.length; i++) {
      final o = toOff(i, points[i].value);
      if (i == 0) linePath.moveTo(o.dx, o.dy); else linePath.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(linePath, Paint()..color = const Color(0xFFFFD79B)..strokeWidth = 2..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    final ts = const TextStyle(color: Colors.grey, fontSize: 9);
    for (final idx in [0, points.length ~/ 2, points.length - 1]) {
      if (idx < 0 || idx >= points.length) continue;
      final label = points[idx].date.length >= 10 ? points[idx].date.substring(5) : points[idx].date;
      final tp = TextPainter(text: TextSpan(text: label, style: ts), textDirection: ui.TextDirection.ltr)..layout();
      final o = toOff(idx, points[idx].value);
      tp.paint(canvas, Offset((o.dx - tp.width / 2).clamp(0.0, size.width - tp.width), size.height - pB + 4));
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.points != points;
}

class _UserGrowthChart extends StatelessWidget {
  final AdminDashboardChartEntity? chart;
  final bool isLoading;
  const _UserGrowthChart({required this.chart, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final points = chart?.points ?? [];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      height: 280,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tăng trưởng người dùng', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Số người dùng mới mỗi ngày', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D2FE), strokeWidth: 2))
                : points.isEmpty
                    ? const Center(child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)))
                    : CustomPaint(painter: _BarChartPainter(points: points), child: const SizedBox.expand()),
          ),
        ],
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<AdminDashboardDailyPointEntity> points;
  const _BarChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final maxVal = points.map((p) => p.value).reduce(math.max).toDouble().clamp(1.0, double.infinity);
    const pT = 4.0; const pB = 20.0; const pH = 4.0;
    final cW = size.width - pH * 2; final cH = size.height - pT - pB;
    final bW = (cW / points.length) * 0.6; final bS = cW / points.length;
    final maxPaint = Paint()..color = const Color(0xFF00D2FE);
    final normPaint = Paint()..color = const Color(0xFF00D2FE).withOpacity(0.6);
    final maxV = points.map((p) => p.value).reduce(math.max);
    for (int i = 0; i < points.length; i++) {
      final bH = (points[i].value / maxVal) * cH;
      final x = pH + i * bS + (bS - bW) / 2;
      final y = pT + cH - bH;
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, bW, bH), const Radius.circular(3)), points[i].value == maxV ? maxPaint : normPaint);
    }
    final ts = const TextStyle(color: Colors.grey, fontSize: 9);
    for (final idx in [0, points.length ~/ 2, points.length - 1]) {
      if (idx < 0 || idx >= points.length) continue;
      final label = points[idx].date.length >= 10 ? points[idx].date.substring(5) : points[idx].date;
      final tp = TextPainter(text: TextSpan(text: label, style: ts), textDirection: ui.TextDirection.ltr)..layout();
      tp.paint(canvas, Offset((pH + idx * bS + bS / 2 - tp.width / 2).clamp(0.0, size.width - tp.width), size.height - pB + 4));
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.points != points;
}

class _TopTracksBar extends StatelessWidget {
  final AdminDashboardTopTracksEntity? topTracks;
  final bool isLoading;
  const _TopTracksBar({required this.topTracks, required this.isLoading});

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final items = topTracks?.items ?? [];
    final maxPlays = items.isEmpty ? 1 : items.map((t) => t.playCount).reduce(math.max);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFF201F1F), borderRadius: BorderRadius.circular(16)),
      height: 350,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top Tracks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const Text('Bài nghe nhiều nhất trong tháng', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFFFD79B), strokeWidth: 2)))
          else if (items.isEmpty)
            const Expanded(child: Center(child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey))))
          else
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final t = items[index];
                  final name = t.title != null ? '${t.title} - ${t.artistName ?? ''}' : t.trackExternalId;
                  final pct = maxPlays == 0 ? 0.0 : t.playCount / maxPlays;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 8),
                          Text(_fmt(t.playCount), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      LinearProgressIndicator(value: pct, backgroundColor: const Color(0xFF2A2A2A), valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD79B)), borderRadius: BorderRadius.circular(4), minHeight: 5),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
