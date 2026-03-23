import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soundtilo/domain/usecases/comment_usecases.dart';
import 'package:soundtilo/presentation/player/bloc/comment_event.dart';
import 'package:soundtilo/presentation/player/bloc/comment_state.dart';

class CommentBloc extends Bloc<CommentEvent, CommentState> {
  final GetCommentsUseCase _getCommentsUseCase;
  final AddCommentUseCase _addCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;

  static const int _pageSize = 20;

  CommentBloc({
    required GetCommentsUseCase getCommentsUseCase,
    required AddCommentUseCase addCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
  })  : _getCommentsUseCase = getCommentsUseCase,
        _addCommentUseCase = addCommentUseCase,
        _deleteCommentUseCase = deleteCommentUseCase,
        super(CommentInitial()) {
    on<CommentLoad>(_onLoad);
    on<CommentLoadMore>(_onLoadMore);
    on<CommentAdd>(_onAdd);
    on<CommentDelete>(_onDelete);
  }

  Future<void> _onLoad(CommentLoad event, Emitter<CommentState> emit) async {
    emit(CommentLoading());

    final result = await _getCommentsUseCase(event.trackExternalId, page: 1, pageSize: _pageSize);

    result.fold(
      (error) => emit(CommentError(error)),
      (data) {
        final (comments, totalCount) = data;
        emit(CommentLoaded(
          comments: comments,
          totalCount: totalCount,
          currentPage: 1,
          hasMore: comments.length >= _pageSize,
        ));
      },
    );
  }

  Future<void> _onLoadMore(CommentLoadMore event, Emitter<CommentState> emit) async {
    final current = state;
    if (current is! CommentLoaded || current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _getCommentsUseCase(event.trackExternalId, page: nextPage, pageSize: _pageSize);

    result.fold(
      (error) => emit(current.copyWith(isLoadingMore: false)),
      (data) {
        final (newComments, totalCount) = data;
        emit(CommentLoaded(
          comments: [...current.comments, ...newComments],
          totalCount: totalCount,
          currentPage: nextPage,
          hasMore: newComments.length >= _pageSize,
        ));
      },
    );
  }

  Future<void> _onAdd(CommentAdd event, Emitter<CommentState> emit) async {
    final current = state;
    if (current is CommentLoaded) {
      emit(current.copyWith(isSubmitting: true));
    }

    final result = await _addCommentUseCase(event.trackExternalId, event.content);

    result.fold(
      (error) {
        if (current is CommentLoaded) {
          emit(current.copyWith(isSubmitting: false));
        }
      },
      (comment) {
        if (current is CommentLoaded) {
          emit(current.copyWith(
            comments: [comment, ...current.comments],
            totalCount: current.totalCount + 1,
            isSubmitting: false,
          ));
        } else {
          emit(CommentLoaded(
            comments: [comment],
            totalCount: 1,
            currentPage: 1,
            hasMore: false,
          ));
        }
      },
    );
  }

  Future<void> _onDelete(CommentDelete event, Emitter<CommentState> emit) async {
    final current = state;
    if (current is! CommentLoaded) return;

    final result = await _deleteCommentUseCase(event.commentId);

    result.fold(
      (_) {},
      (_) {
        final updated = current.comments.where((c) => c.id != event.commentId).toList();
        emit(current.copyWith(
          comments: updated,
          totalCount: current.totalCount - 1,
        ));
      },
    );
  }
}
