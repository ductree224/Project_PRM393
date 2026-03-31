import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_bloc.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_event.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_state.dart';

class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({super.key});

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gửi phản hồi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocListener<FeedbackBloc, FeedbackState>(
        listenWhen: (prev, curr) => prev.formStatus != curr.formStatus,
        listener: (context, state) {
          if (state.formStatus == FeedbackFormStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gửi phản hồi thành công!'),
                backgroundColor: AppColors.successColor,
              ),
            );
            context.read<FeedbackBloc>().add(const FeedbackFormReset());
            Navigator.pop(context, true);
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
                        hintText:
                            'Mô tả chi tiết vấn đề bạn gặp phải...',
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
