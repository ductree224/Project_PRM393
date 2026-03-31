import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/domain/entities/feedback_entity.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_feedback_bloc.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_feedback_event.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_feedback_state.dart';

class AdminFeedbacksPage extends StatefulWidget {
  const AdminFeedbacksPage({super.key});

  @override
  State<AdminFeedbacksPage> createState() => _AdminFeedbacksPageState();
}

class _AdminFeedbacksPageState extends State<AdminFeedbacksPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AdminFeedbackBloc>().add(const AdminFeedbacksLoaded());
    _scrollController.addListener(_onScroll);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        context
            .read<AdminFeedbackBloc>()
            .add(const AdminFeedbackAnalyticsLoaded());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminFeedbackBloc>().add(const AdminFeedbacksLoadMore());
    }
  }

  static const _statusFilters = [
    (null, 'Tất cả'),
    ('pending', 'Chờ xử lý'),
    ('in_progress', 'Đang xử lý'),
    ('resolved', 'Đã giải quyết'),
  ];

  static const _categoryFilters = [
    (null, 'Tất cả'),
    ('general', 'Chung'),
    ('bug', 'Lỗi kỹ thuật'),
    ('ux', 'Trải nghiệm UI/UX'),
    ('performance', 'Hiệu suất'),
    ('payment', 'Thanh toán'),
    ('other', 'Khác'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminFeedbackBloc, AdminFeedbackState>(
      listenWhen: (prev, curr) => prev.handleStatus != curr.handleStatus,
      listener: (context, state) {
        if (state.handleStatus == AdminFeedbackHandleStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xử lý feedback thành công!'),
              backgroundColor: Color(0xFF4CAF4E),
            ),
          );
        } else if (state.handleStatus == AdminFeedbackHandleStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.handleError ?? 'Xử lý thất bại'),
              backgroundColor: const Color(0xFFFF5252),
            ),
          );
        }
      },
      child: Column(
        children: [
          // Tab bar
          TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFFFFD79B),
            labelColor: const Color(0xFFFFD79B),
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Danh sách'),
              Tab(text: 'Thống kê'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedbackList(),
                _buildAnalytics(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Feedback List Tab ──────────────────────────────────────────────────────

  Widget _buildFeedbackList() {
    return Column(
      children: [
        // Filters row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            children: [
              // Status filter
              Expanded(
                child: BlocSelector<AdminFeedbackBloc, AdminFeedbackState,
                    String?>(
                  selector: (state) => state.statusFilter,
                  builder: (context, currentFilter) {
                    return DropdownButtonFormField<String>(
                      value: currentFilter,
                      decoration: _filterDecoration('Trạng thái'),
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: _statusFilters
                          .map((e) => DropdownMenuItem(
                                value: e.$1,
                                child:
                                    Text(e.$2, style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        context.read<AdminFeedbackBloc>().add(
                              AdminFeedbacksStatusFilterChanged(v),
                            );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Category filter
              Expanded(
                child: BlocSelector<AdminFeedbackBloc, AdminFeedbackState,
                    String?>(
                  selector: (state) => state.categoryFilter,
                  builder: (context, currentFilter) {
                    return DropdownButtonFormField<String>(
                      value: currentFilter,
                      decoration: _filterDecoration('Danh mục'),
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      items: _categoryFilters
                          .map((e) => DropdownMenuItem(
                                value: e.$1,
                                child:
                                    Text(e.$2, style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) {
                        context.read<AdminFeedbackBloc>().add(
                              AdminFeedbacksCategoryFilterChanged(v),
                            );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Feedback list
        Expanded(
          child: BlocBuilder<AdminFeedbackBloc, AdminFeedbackState>(
            buildWhen: (prev, curr) =>
                prev.status != curr.status ||
                prev.feedbacks != curr.feedbacks ||
                prev.isLoadingMore != curr.isLoadingMore,
            builder: (context, state) {
              if (state.status == AdminFeedbacksStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.status == AdminFeedbacksStatus.error) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Color(0xFFFF5252)),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage ?? 'Không thể tải danh sách phản hồi',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => context
                            .read<AdminFeedbackBloc>()
                            .add(const AdminFeedbacksLoaded()),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (state.feedbacks.isEmpty) {
                return const Center(
                  child: Text(
                    'Không có phản hồi nào',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<AdminFeedbackBloc>()
                      .add(const AdminFeedbacksLoaded());
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount:
                      state.feedbacks.length + (state.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.feedbacks.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return _AdminFeedbackCard(
                      feedback: state.feedbacks[index],
                      onHandle: () =>
                          _showHandleDialog(state.feedbacks[index]),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Analytics Tab ──────────────────────────────────────────────────────────

  Widget _buildAnalytics() {
    return BlocBuilder<AdminFeedbackBloc, AdminFeedbackState>(
      buildWhen: (prev, curr) =>
          prev.analytics != curr.analytics ||
          prev.isLoadingAnalytics != curr.isLoadingAnalytics,
      builder: (context, state) {
        if (state.isLoadingAnalytics) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = state.analytics;
        if (data == null) {
          return const Center(
            child: Text(
              'Chưa có dữ liệu thống kê',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }

        final total = data['total'] ?? 0;
        final resolved = data['resolved'] ?? 0;
        final resolvedRate = data['resolvedRate'] ?? 0.0;
        final categories = data['categories'] as List? ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  Expanded(
                    child: _AnalyticsCard(
                      title: 'Tổng cộng',
                      value: '$total',
                      icon: Icons.feedback,
                      color: const Color(0xFF42A5F5),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AnalyticsCard(
                      title: 'Đã giải quyết',
                      value: '$resolved',
                      icon: Icons.check_circle,
                      color: const Color(0xFF66BB6A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AnalyticsCard(
                      title: 'Tỉ lệ xử lý',
                      value: '${(resolvedRate * 100).toStringAsFixed(1)}%',
                      icon: Icons.percent,
                      color: const Color(0xFFFFB74D),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                'Theo danh mục',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ...categories.map((cat) {
                final category = cat['category']?.toString() ?? 'unknown';
                final count = cat['count'] ?? 0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _categoryLabel(category),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: total > 0 ? count / total : 0,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFFFD79B)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ─── Handle Dialog ──────────────────────────────────────────────────────────

  void _showHandleDialog(FeedbackEntity feedback) {
    final replyController = TextEditingController();
    String selectedStatus = 'in_progress';
    final bloc = context.read<AdminFeedbackBloc>();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: const Text('Xử lý phản hồi',
                  style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Feedback info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feedback.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feedback.content,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Status selector
                    const Text('Trạng thái',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'in_progress', child: Text('Đang xử lý')),
                        DropdownMenuItem(
                            value: 'resolved', child: Text('Đã giải quyết')),
                      ],
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedStatus = v);
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Reply
                    const Text('Nội dung phản hồi',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: replyController,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Nhập phản hồi cho người dùng...',
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: const Color(0xFF2A2A2A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Huỷ bỏ',
                      style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () {
                    bloc.add(
                      AdminFeedbackHandleRequested(
                        feedbackId: feedback.id,
                        reply: replyController.text.trim(),
                        status: selectedStatus,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD79B),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Xác nhận'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _filterDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      );

  static String _categoryLabel(String raw) {
    switch (raw) {
      case 'bug':
        return 'Lỗi kỹ thuật';
      case 'ux':
        return 'Trải nghiệm UI/UX';
      case 'performance':
        return 'Hiệu suất';
      case 'payment':
        return 'Thanh toán';
      case 'other':
        return 'Khác';
      default:
        return 'Chung';
    }
  }
}

// ─── Reusable widgets ───────────────────────────────────────────────────────

class _AdminFeedbackCard extends StatelessWidget {
  final FeedbackEntity feedback;
  final VoidCallback onHandle;

  const _AdminFeedbackCard({
    required this.feedback,
    required this.onHandle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: title + status
            Row(
              children: [
                Expanded(
                  child: Text(
                    feedback.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: feedback.statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    feedback.statusLabel,
                    style: TextStyle(
                      color: feedback.statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Category + Date
            Row(
              children: [
                _SmallChip(
                    label: feedback.categoryLabel, color: Colors.white54),
                const Spacer(),
                Text(
                  _formatDate(feedback.createdAt),
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // Content preview
            Text(
              feedback.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white60, fontSize: 13),
            ),

            // Admin reply (if already handled)
            if (feedback.hasAdminReply) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '💬 ${feedback.adminReply}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Handle button
            if (!feedback.isResolved)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onHandle,
                  icon: const Icon(Icons.reply, size: 16),
                  label: const Text('Xử lý'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFFD79B),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _SmallChip extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AnalyticsCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
