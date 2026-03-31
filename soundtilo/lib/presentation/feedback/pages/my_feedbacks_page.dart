import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/feedback_entity.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_bloc.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_event.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_state.dart';
import 'package:soundtilo/presentation/feedback/pages/feedback_form_page.dart';

class MyFeedbacksPage extends StatefulWidget {
  const MyFeedbacksPage({super.key});

  @override
  State<MyFeedbacksPage> createState() => _MyFeedbacksPageState();
}

class _MyFeedbacksPageState extends State<MyFeedbacksPage> {
  final ScrollController _scrollController = ScrollController();

  static const _statusFilters = [
    (null, 'Tất cả'),
    ('pending', 'Đã gửi'),
    ('resolved', 'Đã giải quyết'),
  ];

  @override
  void initState() {
    super.initState();
    context.read<FeedbackBloc>().add(const MyFeedbacksLoaded());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FeedbackBloc>().add(const MyFeedbacksLoadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phản hồi của tôi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<FeedbackBloc>(),
                    child: const FeedbackFormPage(),
                  ),
                ),
              );
              if (result == true && mounted) {
                context.read<FeedbackBloc>().add(const MyFeedbacksLoaded());
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Status filter chips ──────────────────────────────────
          BlocSelector<FeedbackBloc, FeedbackState, String?>(
            selector: (state) => state.statusFilter,
            builder: (context, currentFilter) {
              return SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _statusFilters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final (value, label) = _statusFilters[index];
                    final isSelected = currentFilter == value;
                    return FilterChip(
                      selected: isSelected,
                      label: Text(label),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                      onSelected: (_) {
                        context.read<FeedbackBloc>().add(
                              MyFeedbacksStatusFilterChanged(value),
                            );
                      },
                    );
                  },
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          // ─── List ─────────────────────────────────────────────────
          Expanded(
            child: BlocBuilder<FeedbackBloc, FeedbackState>(
              buildWhen: (prev, curr) =>
                  prev.listStatus != curr.listStatus ||
                  prev.feedbacks != curr.feedbacks ||
                  prev.isLoadingMore != curr.isLoadingMore,
              builder: (context, state) {
                if (state.listStatus == MyFeedbacksStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.listStatus == MyFeedbacksStatus.error) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.errorColor),
                        const SizedBox(height: 12),
                        Text(state.listError ?? 'Đã xảy ra lỗi'),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context
                              .read<FeedbackBloc>()
                              .add(const MyFeedbacksLoaded()),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (state.feedbacks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.feedback_outlined,
                            size: 64,
                            color: isDark ? Colors.white30 : Colors.black26),
                        const SizedBox(height: 12),
                        Text(
                          'Bạn chưa có phản hồi nào',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<FeedbackBloc>()
                        .add(const MyFeedbacksLoaded());
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount:
                        state.feedbacks.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.feedbacks.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child:
                              Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _FeedbackCard(
                        feedback: state.feedbacks[index],
                        isDark: isDark,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final FeedbackEntity feedback;
  final bool isDark;

  const _FeedbackCard({required this.feedback, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: title + status badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    feedback.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: feedback.statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    feedback.statusLabel,
                    style: TextStyle(
                      color: feedback.statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Category chip
            _ChipLabel(
              label: feedback.categoryLabel,
              color: AppColors.primary,
            ),

            const SizedBox(height: 8),

            // Content preview
            Text(
              feedback.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white60 : Colors.black54,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 8),

            // Date
            Text(
              _formatDate(feedback.createdAt),
              style: TextStyle(
                color: isDark ? Colors.white38 : Colors.black38,
                fontSize: 12,
              ),
            ),

            // Admin reply (if exists)
            if (feedback.hasAdminReply) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.admin_panel_settings,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text(
                          'Phản hồi từ Admin',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feedback.adminReply!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _ChipLabel extends StatelessWidget {
  final String label;
  final Color color;

  const _ChipLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
