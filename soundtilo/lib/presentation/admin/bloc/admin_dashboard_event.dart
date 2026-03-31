import 'package:equatable/equatable.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

class AdminDashboardStarted extends AdminDashboardEvent {
  final String? month;

  const AdminDashboardStarted({this.month});

  @override
  List<Object?> get props => [month];
}

class AdminDashboardRefresh extends AdminDashboardEvent {
  const AdminDashboardRefresh();
}

class AdminDashboardMonthChanged extends AdminDashboardEvent {
  final String? month;

  const AdminDashboardMonthChanged(this.month);

  @override
  List<Object?> get props => [month];
}
