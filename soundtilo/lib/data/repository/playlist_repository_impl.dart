import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:soundtilo/data/sources/playlist_remote_data_source.dart';
import 'package:soundtilo/domain/entities/playlist_detail_entity.dart';
import 'package:soundtilo/domain/entities/playlist_entity.dart';
import 'package:soundtilo/domain/repository/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistRemoteDataSource _remoteDataSource;

  PlaylistRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<String, List<PlaylistEntity>>> getMyPlaylists() async {
    try {
      final playlists = await _remoteDataSource.getMyPlaylists();
      return Right(playlists);
    } on DioException catch (e) {
      return Left((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể tải playlist.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, PlaylistDetailEntity>> getPlaylistDetail(
    String id,
  ) async {
    try {
      final playlistDetail = await _remoteDataSource.getPlaylistDetail(id);
      return Right(playlistDetail);
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể tải chi tiết playlist.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, PlaylistEntity>> createPlaylist({
    required String name,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      final playlist = await _remoteDataSource.createPlaylist(
        name: name,
        description: description,
        isPublic: isPublic,
      );
      return Right(playlist);
    } on DioException catch (e) {
      return Left((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể tạo playlist.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, PlaylistEntity>> updatePlaylist(
    String id, {
    String? name,
    String? description,
    bool? isPublic,
  }) async {
    try {
      final playlist = await _remoteDataSource.updatePlaylist(
        id,
        name: name,
        description: description,
        isPublic: isPublic,
      );
      return Right(playlist);
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể cập nhật playlist.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> deletePlaylist(String id) async {
    try {
      await _remoteDataSource.deletePlaylist(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể xoá playlist.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> addTrack(
    String playlistId,
    String trackExternalId,
  ) async {
    try {
      await _remoteDataSource.addTrack(playlistId, trackExternalId);
      return const Right(null);
    } on DioException catch (e) {
      return Left((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể thêm bài hát.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> removeTrack(
    String playlistId,
    String trackExternalId,
  ) async {
    try {
      await _remoteDataSource.removeTrack(playlistId, trackExternalId);
      return const Right(null);
    } on DioException catch (e) {
      return Left((e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể xoá bài hát.');
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<Either<String, void>> reorderTracks(
    String playlistId,
    List<String> trackExternalIds,
  ) async {
    try {
      await _remoteDataSource.reorderTracks(playlistId, trackExternalIds);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        (e.response?.data is Map ? e.response?.data['message'] : null) ?? 'Không thể sắp xếp lại playlist.',
      );
    } catch (e) {
      return Left('Đã xảy ra lỗi: $e');
    }
  }
}
