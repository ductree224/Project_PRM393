import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:soundtilo/common/helper/is_dark_mode.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/domain/entities/comment_entity.dart';
import 'package:soundtilo/domain/usecases/comment_usecases.dart';
import 'package:soundtilo/presentation/player/bloc/comment_bloc.dart';
import 'package:soundtilo/presentation/player/bloc/comment_event.dart';
import 'package:soundtilo/presentation/player/bloc/comment_state.dart';

class CommentSheet extends StatefulWidget {
  final String trackExternalId;

  const CommentSheet({super.key, required this.trackExternalId});

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context
          .read<CommentBloc>()
          .add(CommentLoadMore(widget.trackExternalId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final sl = GetIt.instance;
        return CommentBloc(
          getCommentsUseCase: sl<GetCommentsUseCase>(),
          addCommentUseCase: sl<AddCommentUseCase>(),
          deleteCommentUseCase: sl<DeleteCommentUseCase>(),
        )..add(CommentLoad(widget.trackExternalId));
      },
      child: _CommentSheetBody(
        trackExternalId: widget.trackExternalId,
        controller: _controller,
        scrollController: _scrollController,
      ),
    );
  }
}

class _CommentSheetBody extends StatelessWidget {
  final String trackExternalId;
  final TextEditingController controller;
  final ScrollController scrollController;

  const _CommentSheetBody({
    required this.trackExternalId,
    required this.controller,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          BlocBuilder<CommentBloc, CommentState>(
            buildWhen: (prev, curr) =>
                curr is CommentLoaded || curr is CommentLoading,
            builder: (context, state) {
              final count =
                  state is CommentLoaded ? state.totalCount : 0;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Bình luận',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '($count)',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(height: 1),

          // Comments list
          Expanded(
            child: BlocBuilder<CommentBloc, CommentState>(
              builder: (context, state) {
                if (state is CommentLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is CommentError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: AppColors.grey),
                        const SizedBox(height: 8),
                        Text(state.message,
                            style: TextStyle(color: AppColors.grey)),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context
                              .read<CommentBloc>()
                              .add(CommentLoad(trackExternalId)),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is CommentLoaded) {
                  if (state.comments.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 48, color: AppColors.grey),
                          const SizedBox(height: 8),
                          Text(
                            'Chưa có bình luận nào',
                            style: TextStyle(color: AppColors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hãy là người đầu tiên bình luận!',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount:
                        state.comments.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == state.comments.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      return _CommentTile(
                        comment: state.comments[index],
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),

          // Input area
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: _CommentInput(
              controller: controller,
              trackExternalId: trackExternalId,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentEntity comment;

  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Dismissible(
      key: ValueKey(comment.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Xoá bình luận'),
            content:
                const Text('Bạn có chắc muốn xoá bình luận này không?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Huỷ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Xoá',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<CommentBloc>().add(CommentDelete(comment.id));
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.grey.withValues(alpha: 0.2),
              backgroundImage: comment.avatarUrl != null
                  ? CachedNetworkImageProvider(comment.avatarUrl!)
                  : null,
              child: comment.avatarUrl == null
                  ? Text(
                      comment.username.isNotEmpty
                          ? comment.username[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        comment.username,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeAgo(comment.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays > 365) return '${diff.inDays ~/ 365} năm trước';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30} tháng trước';
    if (diff.inDays > 0) return '${diff.inDays} ngày trước';
    if (diff.inHours > 0) return '${diff.inHours} giờ trước';
    if (diff.inMinutes > 0) return '${diff.inMinutes} phút trước';
    return 'Vừa xong';
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final String trackExternalId;

  const _CommentInput({
    required this.controller,
    required this.trackExternalId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppColors.grey.withValues(alpha: 0.2),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        top: false,
        child: BlocSelector<CommentBloc, CommentState, bool>(
          selector: (state) =>
              state is CommentLoaded && state.isSubmitting,
          builder: (context, isSubmitting) {
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLength: 500,
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    enabled: !isSubmitting,
                    decoration: InputDecoration(
                      hintText: 'Viết bình luận...',
                      hintStyle: TextStyle(color: AppColors.grey),
                      counterText: '',
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.grey.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: isSubmitting
                        ? null
                        : (_) => _submit(context),
                  ),
                ),
                const SizedBox(width: 8),
                isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.send_rounded,
                          color: AppColors.primary,
                        ),
                        onPressed: () => _submit(context),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _submit(BuildContext context) {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    context.read<CommentBloc>().add(
          CommentAdd(
            trackExternalId: trackExternalId,
            content: text,
          ),
        );
    controller.clear();
  }
}
