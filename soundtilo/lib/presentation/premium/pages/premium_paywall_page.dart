import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/core/configs/theme/app_colors.dart';
import 'package:soundtilo/core/di/service_locator.dart';
import 'package:soundtilo/domain/entities/subscription_plan_entity.dart';
import 'package:soundtilo/domain/usecases/user_usecases.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_event.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';
import 'package:soundtilo/presentation/premium/pages/vnpay_payment_page.dart';

class PremiumPaywallPage extends StatefulWidget {
  const PremiumPaywallPage({super.key});

  @override
  State<PremiumPaywallPage> createState() => _PremiumPaywallPageState();
}

class _PremiumPaywallPageState extends State<PremiumPaywallPage> {
  List<SubscriptionPlanEntity>? _plans;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final result = await sl<GetSubscriptionPlansUseCase>().call();
    if (!mounted) return;
    result.fold(
      (err) => setState(() {
        _error = err;
        _loading = false;
      }),
      (plans) => setState(() {
        _plans = plans.where((p) => !p.isFree).toList();
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('Nâng cấp Premium'),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _ErrorView(error: _error!, onRetry: _loadPlans)
                : _PaywallContent(plans: _plans ?? []),
      ),
    );
  }
}

// ─── Content ─────────────────────────────────────────────────────────────────

class _PaywallContent extends StatelessWidget {
  final List<SubscriptionPlanEntity> plans;

  const _PaywallContent({required this.plans});

  @override
  Widget build(BuildContext context) {
    final monthlyPlan = plans.cast<SubscriptionPlanEntity?>().firstWhere(
          (p) => p?.isMonthly == true,
          orElse: () => null,
        );
    final yearlyPlan = plans.cast<SubscriptionPlanEntity?>().firstWhere(
          (p) => p?.isYearly == true,
          orElse: () => null,
        );

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        // Header
        const _PaywallHeader(),
        const SizedBox(height: 32),

        // Feature list (placeholders — dev fills in actual features)
        const _FeatureList(),
        const SizedBox(height: 32),

        // Yearly plan card (highlighted as best value)
        if (yearlyPlan != null) ...[
          _PlanCard(plan: yearlyPlan, highlighted: true),
          const SizedBox(height: 12),
        ],

        // Monthly plan card
        if (monthlyPlan != null) ...[
          _PlanCard(plan: monthlyPlan, highlighted: false),
          const SizedBox(height: 24),
        ],

        // Fallback if no plans loaded
        if (plans.isEmpty)
          const Center(child: Text('Không có gói nào hiện tại.')),

        // Current subscription status
        _CurrentStatusBanner(),

        const SizedBox(height: 16),
        const _DisclaimerText(),
      ],
    );
  }
}

class _PaywallHeader extends StatelessWidget {
  const _PaywallHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFEE7700), Color(0xFFFFA126)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Icon(Icons.star_rounded, size: 44, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'Soundtilo Premium',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mở khóa toàn bộ trải nghiệm âm nhạc',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.grey),
        ),
      ],
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  // TODO: Dev điền vào các tính năng thực tế khi implement premium features.
  static const _features = [
    (Icons.music_note_rounded, 'Chất lượng âm thanh cao (320kbps)'),
    (Icons.download_rounded, 'Tải nhạc nghe offline'),
    (Icons.shuffle_rounded, 'Shuffle & Repeat không giới hạn'),
    (Icons.skip_next_rounded, 'Skip không giới hạn'),
    (Icons.subtitles_rounded, 'Xem lời bài hát đầy đủ'),
    (Icons.queue_music_rounded, 'Hàng chờ phát không giới hạn'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _features.map((f) => _FeatureRow(icon: f.$1, label: f.$2)).toList(),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0x22EE7700),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Icon(Icons.check_circle_rounded,
              size: 18, color: AppColors.successColor),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlanEntity plan;
  final bool highlighted;

  const _PlanCard({required this.plan, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final savings = plan.yearlySavings;
    return Container(
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.primary.withValues(alpha: 0.08)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? AppColors.primary : Colors.transparent,
          width: highlighted ? 2 : 0,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      plan.isYearly ? '1 năm' : '1 tháng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (savings != null && savings > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Tiết kiệm ${plan.formattedSavings}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.successColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (plan.isYearly && plan.monthlyEquivalent != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: _formattedSmallPrice(
                      context,
                      plan.monthlyEquivalent!,
                      plan.currency,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                plan.formattedPrice,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: highlighted ? AppColors.primary : null,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                plan.isYearly ? '/năm' : '/tháng',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _onSubscribeTapped(context, plan),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  highlighted ? AppColors.primary : null,
              foregroundColor: highlighted ? Colors.white : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Đăng ký'),
          ),
        ],
      ),
    );
  }

  Widget _formattedSmallPrice(
      BuildContext context, double monthly, String currency) {
    final p = monthly.toInt();
    final formatted = p.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return Text(
      '~${formatted}đ/tháng',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey,
          ),
    );
  }

  void _onSubscribeTapped(BuildContext context, SubscriptionPlanEntity plan) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Create VNPay payment URL
    final result = await sl<CreatePaymentUrlUseCase>().call(plan.id);

    if (!context.mounted) return;
    Navigator.pop(context); // dismiss loading

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.errorColor,
          ),
        );
      },
      (data) async {
        // Open VNPay WebView
        final success = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => VnpayPaymentPage(
              paymentUrl: data.paymentUrl,
              txnRef: data.txnRef,
            ),
          ),
        );

        if (!context.mounted) return;

        if (success == true) {
          // Refresh user profile to get updated subscription status
          context.read<AuthBloc>().add(AuthProfileRefreshRequested());

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Nâng cấp Premium thành công!'),
              backgroundColor: AppColors.successColor,
            ),
          );

          // Pop back to previous screen
          Navigator.pop(context);
        } else if (success == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán bị hủy hoặc thất bại.'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      },
    );
  }
}

class _CurrentStatusBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) return const SizedBox.shrink();
        final user = state.user;
        if (!user.isPremium) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.successColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.successColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.successColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bạn đang dùng Premium',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.successColor,
                          ),
                    ),
                    if (user.premiumExpiresAt != null)
                      Text(
                        'Hết hạn: ${_formatDate(user.premiumExpiresAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.grey,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.errorColor),
          const SizedBox(height: 12),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Thử lại')),
        ],
      ),
    );
  }
}

class _DisclaimerText extends StatelessWidget {
  const _DisclaimerText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Bằng cách đăng ký, bạn đồng ý với Điều khoản dịch vụ của Soundtilo. '
      'Gói thuê bao tự động gia hạn trừ khi bị hủy trước ngày gia hạn.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey,
            fontSize: 11,
          ),
    );
  }
}
