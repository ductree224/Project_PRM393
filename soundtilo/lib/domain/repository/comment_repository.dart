import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/entities/comment_entity.dart';

abstract class CommentRepository {
  Future<Either<String, (List<CommentEntity>, int)>> getComments(
    String trackExternalId, {
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<String, CommentEntity>> addComment(
    String trackExternalId,
    String content,
  );
  Future<Either<String, void>> deleteComment(String commentId);
}
