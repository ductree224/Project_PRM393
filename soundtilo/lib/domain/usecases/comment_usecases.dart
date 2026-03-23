import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/comment_entity.dart';
import 'package:soundtilo/domain/repository/comment_repository.dart';

class GetCommentsUseCase {
  final CommentRepository repository;

  GetCommentsUseCase(this.repository);

  Future<Either<String, (List<CommentEntity>, int)>> call(
    String trackExternalId, {
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.getComments(trackExternalId, page: page, pageSize: pageSize);
  }
}

class AddCommentUseCase {
  final CommentRepository repository;

  AddCommentUseCase(this.repository);

  Future<Either<String, CommentEntity>> call(
    String trackExternalId,
    String content,
  ) {
    return repository.addComment(trackExternalId, content);
  }
}

class DeleteCommentUseCase {
  final CommentRepository repository;

  DeleteCommentUseCase(this.repository);

  Future<Either<String, void>> call(String commentId) {
    return repository.deleteComment(commentId);
  }
}
