import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/domain/usecases/feedback_usecases.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_feedback_event.dart';
import 'package:soundtilo/presentation/admin/bloc/admin_feedback_state.dart';

class AdminFeedbackBloc extends Bloc<AdminFeedbackEvent, AdminFeedbackState> {
  final AdminGetFeedbacksUseCase _adminGetFeedbacksUseCase;
  final HandleFeedbackUseCase _handleFeedbackUseCase;
  final GetFeedbackAnalyticsUseCase _getFeedbackAnalyticsUseCase;

  AdminFeedbackBloc({
    required AdminGetFeedbacksUseCase adminGetFeedbacksUseCase,
    required HandleFeedbackUseCase handleFeedbackUseCase,
    required GetFeedbackAnalyticsUseCase getFeedbackAnalyticsUseCase,
  })  : _adminGetFeedbacksUseCase = adminGetFeedbacksUseCase,
        _handleFeedbackUseCase = handleFeedbackUseCase,
        _getFeedbackAnalyticsUseCase = getFeedbackAnalyticsUseCase,
        super(const AdminFeedbackState()) {
    on<AdminFeedbacksLoaded>(_onLoaded);
    on<AdminFeedbacksLoadMore>(_onLoadMore);
    on<AdminFeedbacksStatusFilterChanged>(_onStatusFilterChanged);
    on<AdminFeedbacksCategoryFilterChanged>(_onCategoryFilterChanged);
    on<AdminFeedbackHandleRequested>(_onHandleRequested);
    on<AdminFeedbackAnalyticsLoaded>(_onAnalyticsLoaded);
  }

  Future<void> _onLoaded(
    AdminFeedbacksLoaded event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    emit(state.copyWith(status: AdminFeedbacksStatus.loading));

    final result = await _adminGetFeedbacksUseCase(
      status: state.statusFilter,
      category: state.categoryFilter,
      page: 1,
      pageSize: state.pageSize,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: AdminFeedbacksStatus.error,
        errorMessage: error,
      )),
      (data) {
        final (items, total) = data;
        emit(state.copyWith(
          status: AdminFeedbacksStatus.loaded,
          feedbacks: items,
          total: total,
          page: 1,
          hasMore: items.length < total,
        ));
      },
    );
  }

  Future<void> _onLoadMore(
    AdminFeedbacksLoadMore event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.page + 1;

    final result = await _adminGetFeedbacksUseCase(
      status: state.statusFilter,
      category: state.categoryFilter,
      page: nextPage,
      pageSize: state.pageSize,
    );

    result.fold(
      (error) =>
          emit(state.copyWith(isLoadingMore: false, errorMessage: error)),
      (data) {
        final (items, total) = data;
        final newList = [...state.feedbacks, ...items];
        emit(state.copyWith(
          feedbacks: newList,
          total: total,
          page: nextPage,
          isLoadingMore: false,
          hasMore: newList.length < total,
        ));
      },
    );
  }

  Future<void> _onStatusFilterChanged(
    AdminFeedbacksStatusFilterChanged event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    emit(AdminFeedbackState(
      statusFilter: event.status,
      categoryFilter: state.categoryFilter,
      status: AdminFeedbacksStatus.loading,
      analytics: state.analytics,
    ));

    final result = await _adminGetFeedbacksUseCase(
      status: event.status,
      category: state.categoryFilter,
      page: 1,
      pageSize: state.pageSize,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: AdminFeedbacksStatus.error,
        errorMessage: error,
      )),
      (data) {
        final (items, total) = data;
        emit(state.copyWith(
          status: AdminFeedbacksStatus.loaded,
          feedbacks: items,
          total: total,
          page: 1,
          hasMore: items.length < total,
        ));
      },
    );
  }

  Future<void> _onCategoryFilterChanged(
    AdminFeedbacksCategoryFilterChanged event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    emit(AdminFeedbackState(
      statusFilter: state.statusFilter,
      categoryFilter: event.category,
      status: AdminFeedbacksStatus.loading,
      analytics: state.analytics,
    ));

    final result = await _adminGetFeedbacksUseCase(
      status: state.statusFilter,
      category: event.category,
      page: 1,
      pageSize: state.pageSize,
    );

    result.fold(
      (error) => emit(state.copyWith(
        status: AdminFeedbacksStatus.error,
        errorMessage: error,
      )),
      (data) {
        final (items, total) = data;
        emit(state.copyWith(
          status: AdminFeedbacksStatus.loaded,
          feedbacks: items,
          total: total,
          page: 1,
          hasMore: items.length < total,
        ));
      },
    );
  }

  Future<void> _onHandleRequested(
    AdminFeedbackHandleRequested event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    emit(state.copyWith(handleStatus: AdminFeedbackHandleStatus.processing));

    final result = await _handleFeedbackUseCase(
      feedbackId: event.feedbackId,
      reply: event.reply,
      status: event.status,
    );

    result.fold(
      (error) => emit(state.copyWith(
        handleStatus: AdminFeedbackHandleStatus.failure,
        handleError: error,
      )),
      (_) {
        emit(state.copyWith(handleStatus: AdminFeedbackHandleStatus.success));
        // Reload list
        add(const AdminFeedbacksLoaded());
      },
    );
  }

  Future<void> _onAnalyticsLoaded(
    AdminFeedbackAnalyticsLoaded event,
    Emitter<AdminFeedbackState> emit,
  ) async {
    emit(state.copyWith(isLoadingAnalytics: true));

    final result = await _getFeedbackAnalyticsUseCase(days: event.days);

    result.fold(
      (error) => emit(state.copyWith(isLoadingAnalytics: false)),
      (data) => emit(state.copyWith(
        analytics: data,
        isLoadingAnalytics: false,
      )),
    );
  }
}
