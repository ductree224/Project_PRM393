import 'package:equatable/equatable.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_user_detail_state.dart';

abstract class AdminUserDetailEvent extends Equatable {
  const AdminUserDetailEvent();

  @override
  List<Object?> get props => [];
}

class AdminUserDetailStarted extends AdminUserDetailEvent {
  final String userId;
  final AdminUserDetailSection section;

  const AdminUserDetailStarted({required this.userId, required this.section});

  @override
  List<Object?> get props => [userId, section];
}

class AdminUserDetailRefresh extends AdminUserDetailEvent {
  const AdminUserDetailRefresh();
}

class AdminUserDetailLoadMore extends AdminUserDetailEvent {
  const AdminUserDetailLoadMore();
}
