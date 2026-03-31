import 'package:equatable/equatable.dart';
import 'package:soundtilo/domain/entities/admin_dashboard_entity.dart';

enum AdminDashboardStatus { initial, loading, success, error }

class AdminDashboardState extends Equatable {
  final AdminDashboardStatus status;
  final AdminDashboardSummaryEntity? summary;
  final AdminDashboardChartEntity? playTrend;
  final AdminDashboardChartEntity? userGrowth;
  final AdminDashboardTopTracksEntity? topTracks;
  final String? selectedMonth;
  final String? errorMessage;

  const AdminDashboardState({
    this.status = AdminDashboardStatus.initial,
    this.summary,
    this.playTrend,
    this.userGrowth,
    this.topTracks,
    this.selectedMonth,
    this.errorMessage,
  });

  AdminDashboardState copyWith({
    AdminDashboardStatus? status,
    AdminDashboardSummaryEntity? summary,
    AdminDashboardChartEntity? playTrend,
    AdminDashboardChartEntity? userGrowth,
    AdminDashboardTopTracksEntity? topTracks,
    String? selectedMonth,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminDashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      playTrend: playTrend ?? this.playTrend,
      userGrowth: userGrowth ?? this.userGrowth,
      topTracks: topTracks ?? this.topTracks,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    summary,
    playTrend,
    userGrowth,
    topTracks,
    selectedMonth,
    errorMessage,
  ];
}
