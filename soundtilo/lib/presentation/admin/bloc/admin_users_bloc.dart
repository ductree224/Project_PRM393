import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/domain/usecases/admin_user_usecases.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_users_event.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final GetAdminUsersUseCase _getAdminUsersUseCase;
  final BanAdminUserUseCase _banAdminUserUseCase;
  final UnbanAdminUserUseCase _unbanAdminUserUseCase;
  final ChangeAdminUserRoleUseCase _changeAdminUserRoleUseCase;
  final DeleteAdminUserUseCase _deleteAdminUserUseCase;

  AdminUsersBloc({
    required GetAdminUsersUseCase getAdminUsersUseCase,
    required BanAdminUserUseCase banAdminUserUseCase,
    required UnbanAdminUserUseCase unbanAdminUserUseCase,
    required ChangeAdminUserRoleUseCase changeAdminUserRoleUseCase,
    required DeleteAdminUserUseCase deleteAdminUserUseCase,
  }) : _getAdminUsersUseCase = getAdminUsersUseCase,
       _banAdminUserUseCase = banAdminUserUseCase,
       _unbanAdminUserUseCase = unbanAdminUserUseCase,
       _changeAdminUserRoleUseCase = changeAdminUserRoleUseCase,
       _deleteAdminUserUseCase = deleteAdminUserUseCase,
       super(const AdminUsersState()) {
    on<AdminUsersStarted>(_onStarted, transformer: droppable());
    on<AdminUsersSearchChanged>(_onSearchChanged, transformer: restartable());
    on<AdminUsersRoleFilterChanged>(
      _onRoleFilterChanged,
      transformer: restartable(),
    );
    on<AdminUsersBanFilterChanged>(
      _onBanFilterChanged,
      transformer: restartable(),
    );
    on<AdminUsersLoadMore>(_onLoadMore, transformer: droppable());
    on<AdminUsersRefresh>(_onRefresh, transformer: droppable());
    on<AdminUsersBanToggleRequested>(_onBanToggleRequested);
    on<AdminUsersRoleChangeRequested>(_onRoleChangeRequested);
    on<AdminUsersDeleteRequested>(_onDeleteRequested);
  }

  Future<void> _onStarted(
    AdminUsersStarted event,
    Emitter<AdminUsersState> emit,
  ) async {
    await _loadUsers(emit, reset: true);
  }

  Future<void> _onSearchChanged(
    AdminUsersSearchChanged event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(state.copyWith(search: event.query));
    await _loadUsers(emit, reset: true);
  }

  Future<void> _onRoleFilterChanged(
    AdminUsersRoleFilterChanged event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(state.copyWith(role: event.role));
    await _loadUsers(emit, reset: true);
  }

  Future<void> _onBanFilterChanged(
    AdminUsersBanFilterChanged event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(state.copyWith(isBanned: event.isBanned));
    await _loadUsers(emit, reset: true);
  }

  Future<void> _onLoadMore(
    AdminUsersLoadMore event,
    Emitter<AdminUsersState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) {
      return;
    }

    emit(state.copyWith(isLoadingMore: true, errorMessage: null));
    final nextPage = state.page + 1;

    final result = await _getAdminUsersUseCase(
      page: nextPage,
      pageSize: state.pageSize,
      search: state.search,
      role: state.role,
      isBanned: state.isBanned,
    );

    result.fold(
      (error) =>
          emit(state.copyWith(isLoadingMore: false, errorMessage: error)),
      (data) {
        emit(
          state.copyWith(
            status: AdminUsersStatus.loaded,
            users: [...state.users, ...data.users],
            page: data.page,
            pageSize: data.pageSize,
            total: data.total,
            totalPages: data.totalPages,
            isLoadingMore: false,
            errorMessage: null,
          ),
        );
      },
    );
  }

  Future<void> _onRefresh(
    AdminUsersRefresh event,
    Emitter<AdminUsersState> emit,
  ) async {
    await _loadUsers(emit, reset: true);
  }

  Future<void> _onBanToggleRequested(
    AdminUsersBanToggleRequested event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        actionMessage: null,
        errorMessage: null,
      ),
    );

    final result = event.isCurrentlyBanned
        ? await _unbanAdminUserUseCase(event.userId)
        : await _banAdminUserUseCase(event.userId, reason: event.reason);

    await result.fold(
      (error) async {
        emit(state.copyWith(isSubmitting: false, errorMessage: error));
      },
      (_) async {
        emit(
          state.copyWith(
            isSubmitting: false,
            actionMessage: event.isCurrentlyBanned
                ? 'Đã mở khóa tài khoản.'
                : 'Đã khóa tài khoản.',
          ),
        );
        // Refresh silently to keep UI stable
        await _loadUsers(emit, reset: false, silent: true);
      },
    );
  }

  Future<void> _onRoleChangeRequested(
    AdminUsersRoleChangeRequested event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        actionMessage: null,
        errorMessage: null,
      ),
    );

    final result = await _changeAdminUserRoleUseCase(
      event.userId,
      event.newRole,
    );

    await result.fold(
      (error) async =>
          emit(state.copyWith(isSubmitting: false, errorMessage: error)),
      (_) async {
        emit(
          state.copyWith(
            isSubmitting: false,
            actionMessage: 'Đã cập nhật quyền ${event.newRole}.',
          ),
        );
        await _loadUsers(emit, reset: false, silent: true);
      },
    );
  }

  Future<void> _onDeleteRequested(
    AdminUsersDeleteRequested event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        actionMessage: null,
        errorMessage: null,
      ),
    );

    final result = await _deleteAdminUserUseCase(event.userId);

    await result.fold(
      (error) async =>
          emit(state.copyWith(isSubmitting: false, errorMessage: error)),
      (_) async {
        emit(
          state.copyWith(isSubmitting: false, actionMessage: 'Đã xóa user.'),
        );
        await _loadUsers(emit, reset: false, silent: true);
      },
    );
  }

  Future<void> _loadUsers(
    Emitter<AdminUsersState> emit, {
    required bool reset,
    bool silent = false,
  }) async {
    if (reset) {
      emit(
        state.copyWith(
          status: AdminUsersStatus.loading,
          page: 1,
          users: const [],
          errorMessage: null,
          actionMessage: null,
        ),
      );
    } else if (!silent) {
      emit(state.copyWith(
        status: AdminUsersStatus.loading, 
        errorMessage: null,
        actionMessage: null, // Clear messages when starting load
      ));
    }

    final result = await _getAdminUsersUseCase(
      page: 1,
      pageSize: state.pageSize,
      search: state.search,
      role: state.role,
      isBanned: state.isBanned,
    );

    result.fold(
      (error) {
        emit(
          state.copyWith(
            status: AdminUsersStatus.error,
            errorMessage: error,
            isLoadingMore: false,
            actionMessage: null,
          ),
        );
      },
      (data) {
        emit(
          state.copyWith(
            status: AdminUsersStatus.loaded,
            users: data.users,
            page: data.page,
            pageSize: data.pageSize,
            total: data.total,
            totalPages: data.totalPages,
            isLoadingMore: false,
            errorMessage: null,
            actionMessage: null, // Ensure message is cleared after load
          ),
        );
      },
    );
  }
}
