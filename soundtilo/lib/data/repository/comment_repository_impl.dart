import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/sources/comment_remote_data_source.dart';
import 'package:soundtilo/domain/entities/comment_entity.dart';
import 'package:soundtilo/domain/repository/comment_repository.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource _remoteDataSource;

  CommentRepositoryImpl(this._remoteDataSource);

  CommentEntity _mapToEntity(Map<String, dynamic> json) {
    return CommentEntity(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<Either<String, (List<CommentEntity>, int)>> getComments(
    String trackExternalId, {
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final data = await _remoteDataSource.getComments(
        trackExternalId,
        page: page,
        pageSize: pageSize,
      );
      final comments = (data['comments'] as List?)
              ?.map((c) => _mapToEntity(c as Map<String, dynamic>))
              .toList() ??
          [];
      final totalCount = (data['totalCount'] as num?)?.toInt() ?? 0;
      return Right((comments, totalCount));
    } on DioException catch (e) {
      return Left((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể tải bình luận.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, CommentEntity>> addComment(
    String trackExternalId,
    String content,
  ) async {
    try {
      final data = await _remoteDataSource.addComment(trackExternalId, content);
      return Right(_mapToEntity(data));
    } on DioException catch (e) {
      return Left((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể gửi bình luận.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteComment(String commentId) async {
    try {
      await _remoteDataSource.deleteComment(commentId);
      return const Right(null);
    } on DioException catch (e) {
      return Left((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể xoá bình luận.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
