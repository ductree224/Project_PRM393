import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_bloc.dart';
import 'package:soundtilo/presentation/auth/bloc/auth_state.dart';
import 'package:soundtilo/presentation/premium/pages/premium_paywall_page.dart';

/// Wraps any widget behind a premium check.
///
/// Usage:
/// ```dart
/// PremiumGate(child: MyPremiumWidget())
/// ```
///
/// When the user is not premium, [fallback] is shown instead.
/// If [fallback] is null, tapping the lock area navigates to [PremiumPaywallPage].
///
/// Dev note: wrap any UI element, button, or page with this widget to
/// gate it behind premium. The BLoC state is read from the nearest
/// [AuthBloc] in the widget tree.
class PremiumGate extends StatelessWidget {
  final Widget child;

  /// Optional widget to show instead of [child] for non-premium users.
  /// If null, a [_PremiumLockOverlay] with a paywall navigation CTA is shown.
  final Widget? fallback;

  const PremiumGate({super.key, required this.child, this.fallback});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) {
        // Only rebuild when authentication or subscription status changes.
        if (prev is AuthAuthenticated && curr is AuthAuthenticated) {
          return prev.user.isPremium != curr.user.isPremium;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        final isPremium =
            state is AuthAuthenticated && state.user.isPremium;
        if (isPremium) return child;
        return fallback ??
            _PremiumLockOverlay(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PremiumPaywallPage(),
                ),
              ),
            );
      },
    );
  }
}

class _PremiumLockOverlay extends StatelessWidget {
  final VoidCallback onTap;

  const _PremiumLockOverlay({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFEE7700).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, size: 18, color: Color(0xFFEE7700)),
            const SizedBox(width: 8),
            Text(
              'Tính năng Premium',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFEE7700),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
