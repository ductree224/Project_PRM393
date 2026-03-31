import 'dart:io' show Platform;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/domain/usecases/feedback_usecases.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_event.dart';
import 'package:soundtilo/presentation/feedback/bloc/feedback_state.dart';

class FeedbackBloc extends Bloc<FeedbackEvent, FeedbackState> {
  final CreateFeedbackUseCase _createFeedbackUseCase;
  final GetMyFeedbacksUseCase _getMyFeedbacksUseCase;

  FeedbackBloc({
    required CreateFeedbackUseCase createFeedbackUseCase,
    required GetMyFeedbacksUseCase getMyFeedbacksUseCase,
  })  : _createFeedbackUseCase = createFeedbackUseCase,
        _getMyFeedbacksUseCase = getMyFeedbacksUseCase,
        super(const FeedbackState()) {
    on<FeedbackFormSubmitted>(_onFormSubmitted);
    on<FeedbackFormReset>(_onFormReset);
    on<MyFeedbacksLoaded>(_onMyFeedbacksLoaded);
    on<MyFeedbacksLoadMore>(_onMyFeedbacksLoadMore);
    on<MyFeedbacksStatusFilterChanged>(_onStatusFilterChanged);
  }

  Future<void> _onFormSubmitted(
    FeedbackFormSubmitted event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(formStatus: FeedbackFormStatus.submitting));

    String? platformName;
    try {
      platformName = Platform.operatingSystem;
    } catch (_) {
      platformName = 'unknown';
    }

    final result = await _createFeedbackUseCase(
      category: event.category,
      priority: 'medium',
      title: event.title,
      content: event.content,
      platform: platformName,
    );

    result.fold(
      (error) => emit(state.copyWith(
        formStatus: FeedbackFormStatus.failure,
        formError: error,
      )),
      (_) => emit(state.copyWith(formStatus: FeedbackFormStatus.success)),
    );
  }

  void _onFormReset(FeedbackFormReset event, Emitter<FeedbackState> emit) {
    emit(state.copyWith(formStatus: FeedbackFormStatus.initial));
  }

  Future<void> _onMyFeedbacksLoaded(
    MyFeedbacksLoaded event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(state.copyWith(listStatus: MyFeedbacksStatus.loading));

    final result = await _getMyFeedbacksUseCase(
      status: state.statusFilter,
      page: 1,
      pageSize: state.pageSize,
    );

    result.fold(
      (error) => emit(state.copyWith(
        listStatus: MyFeedbacksStatus.error,
        listError: error,
      )),
      (data) {
        final (items, total) = data;
        emit(state.copyWith(
          listStatus: MyFeedbacksStatus.loaded,
          feedbacks: items,
          total: total,
          page: 1,
          hasMore: items.length < total,
        ));
      },
    );
  }

  Future<void> _onMyFeedbacksLoadMore(
    MyFeedbacksLoadMore event,
    Emitter<FeedbackState> emit,
  ) async {
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));
    final nextPage = state.page + 1;

    final result = await _getMyFeedbacksUseCase(
      status: state.statusFilter,
      page: nextPage,
      pageSize: state.pageSize,
    );

    result.fold(
      (error) => emit(state.copyWith(isLoadingMore: false, listError: error)),
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
    MyFeedbacksStatusFilterChanged event,
    Emitter<FeedbackState> emit,
  ) async {
    emit(FeedbackState(
      formStatus: state.formStatus,
      statusFilter: event.status,
      listStatus: MyFeedbacksStatus.loading,
    ));

    final result = await _getMyFeedbacksUseCase(
      status: event.status,
      page: 1,
      pageSize: state.pageSize,
    );

    result.fold(
      (error) => emit(state.copyWith(
        listStatus: MyFeedbacksStatus.error,
        listError: error,
      )),
      (data) {
        final (items, total) = data;
        emit(state.copyWith(
          listStatus: MyFeedbacksStatus.loaded,
          feedbacks: items,
          total: total,
          page: 1,
          hasMore: items.length < total,
        ));
      },
    );
  }
}
