import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/feedback_entity.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_bloc.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_event.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_state.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1 && !_tabController.indexIsChanging) {
        // Load feedbacks when switching to list tab
        context.read<FeedbackBloc>().add(const MyFeedbacksLoaded());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phản hồi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Gửi phản hồi'),
            Tab(text: 'Phản hồi của tôi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _FeedbackFormTab(
            onSubmitSuccess: () {
              // Switch to list tab and reload after successful submission
              _tabController.animateTo(1);
              context.read<FeedbackBloc>().add(const MyFeedbacksLoaded());
            },
          ),
          const _MyFeedbacksTab(),
        ],
      ),
    );
  }
}

// ─── Tab 0: Send Feedback Form ──────────────────────────────────────────────

class _FeedbackFormTab extends StatefulWidget {
  final VoidCallback onSubmitSuccess;

  const _FeedbackFormTab({required this.onSubmitSuccess});

  @override
  State<_FeedbackFormTab> createState() => _FeedbackFormTabState();
}

class _FeedbackFormTabState extends State<_FeedbackFormTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _category = 'general';

  static const _categories = [
    ('general', 'Chung'),
    ('bug', 'Lỗi kỹ thuật'),
    ('ux', 'Trải nghiệm UI/UX'),
    ('performance', 'Hiệu suất'),
    ('payment', 'Thanh toán'),
    ('other', 'Khác'),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<FeedbackBloc>().add(FeedbackFormSubmitted(
          category: _category,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<FeedbackBloc, FeedbackState>(
      listenWhen: (prev, curr) => prev.formStatus != curr.formStatus,
      listener: (context, state) {
        if (state.formStatus == FeedbackFormStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gửi phản hồi thành công!'),
              backgroundColor: AppColors.successColor,
            ),
          );
          // Reset form
          _titleController.clear();
          _contentController.clear();
          setState(() => _category = 'general');
          context.read<FeedbackBloc>().add(const FeedbackFormReset());
          widget.onSubmitSuccess();
        } else if (state.formStatus == FeedbackFormStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.formError ?? 'Gửi phản hồi thất bại.'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      },
      child: BlocBuilder<FeedbackBloc, FeedbackState>(
        buildWhen: (prev, curr) => prev.formStatus != curr.formStatus,
        builder: (context, state) {
          final isSubmitting =
              state.formStatus == FeedbackFormStatus.submitting;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Category ────────────────────────────────────
                  Text(
                    'Danh mục',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _category,
                    decoration: _inputDecoration(isDark),
                    dropdownColor:
                        isDark ? const Color(0xFF2A2A2A) : Colors.white,
                    items: _categories
                        .map((e) => DropdownMenuItem(
                              value: e.$1,
                              child: Text(e.$2),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _category = v);
                    },
                  ),

                  const SizedBox(height: 16),

                  // ─── Title ───────────────────────────────────────
                  Text(
                    'Tiêu đề',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _titleController,
                    enabled: !isSubmitting,
                    maxLength: 200,
                    decoration: _inputDecoration(isDark).copyWith(
                      hintText: 'Mô tả ngắn gọn vấn đề...',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Vui lòng nhập tiêu đề.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ─── Content ─────────────────────────────────────
                  Text(
                    'Nội dung chi tiết',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _contentController,
                    enabled: !isSubmitting,
                    maxLines: 6,
                    maxLength: 2000,
                    decoration: _inputDecoration(isDark).copyWith(
                      hintText: 'Mô tả chi tiết vấn đề bạn gặp phải...',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Vui lòng nhập nội dung.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // ─── Submit button ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Gửi phản hồi',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark) => InputDecoration(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white12 : Colors.black12,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}

// ─── Tab 1: My Feedbacks List ───────────────────────────────────────────────

class _MyFeedbacksTab extends StatefulWidget {
  const _MyFeedbacksTab();

  @override
  State<_MyFeedbacksTab> createState() => _MyFeedbacksTabState();
}

class _MyFeedbacksTabState extends State<_MyFeedbacksTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  static const _statusFilters = [
    (null, 'Tất cả'),
    ('pending', 'Đã gửi'),
    ('resolved', 'Đã giải quyết'),
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
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
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
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
                        child: Center(child: CircularProgressIndicator()),
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
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────

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
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
