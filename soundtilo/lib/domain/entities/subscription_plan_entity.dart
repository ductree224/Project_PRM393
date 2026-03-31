import 'package:equatable/equatable.dart';

class SubscriptionPlanEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final String currency;

  /// 'free' | 'monthly' | 'yearly'
  final String interval;

  /// For yearly plans: the per-month cost (price / 12), rounded.
  /// Used to calculate and display savings vs. monthly billing.
  final double? monthlyEquivalent;

  const SubscriptionPlanEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.interval,
    this.monthlyEquivalent,
  });

  bool get isYearly => interval == 'yearly';
  bool get isMonthly => interval == 'monthly';
  bool get isFree => interval == 'free';

  /// Savings in VND compared to paying monthly for 12 months.
  double? get yearlySavings {
    if (!isYearly || monthlyEquivalent == null) return null;
    return (monthlyEquivalent! * 12) - price;
  }

  String get formattedPrice {
    if (price == 0) return 'Miễn phí';
    final p = price.toInt();
    // Format as Vietnamese currency: 10000 → "10.000đ"
    final formatted = p.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '${formatted}đ';
  }

  String get formattedSavings {
    final s = yearlySavings;
    if (s == null) return '';
    final formatted = s.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return '${formatted}đ';
  }

  @override
  List<Object?> get props =>
      [id, name, price, currency, interval, monthlyEquivalent];
}
