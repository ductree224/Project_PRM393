import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/album_repository.dart';
import '../models/album_model.dart';
import '../sources/album_remote_data_source.dart';

class AlbumRepositoryImpl implements AlbumRepository {
  final AlbumRemoteDataSource _remoteDataSource;

  AlbumRepositoryImpl(this._remoteDataSource);

  String _resolveDioErrorMessage(dynamic responseData, String fallback) {
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
      return fallback;
    }
    if (responseData is String && responseData.trim().isNotEmpty) {
      return responseData;
    }
    return fallback;
  }

  @override
  Future<Either<String, List<AlbumModel>>> getAlbums({String? tag, String? artistId}) async {
    try {
      final remoteData = await _remoteDataSource.getAlbums(tag: tag, artistId: artistId);
      return Right(remoteData);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to get albums.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, AlbumModel>> getAlbumById(String id, {bool includeTracks = false}) async {
    try {
      final remoteData = await _remoteDataSource.getAlbumById(id, includeTracks: includeTracks);
      return Right(remoteData);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to get album.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> addTrack(String albumId, String trackExternalId, int position) async {
    try {
      await _remoteDataSource.addTrack(albumId, trackExternalId, position);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to add track to album.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> removeTrack(String albumId, String trackExternalId) async {
    try {
      await _remoteDataSource.removeTrack(albumId, trackExternalId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to remove track from album.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, AlbumModel>> createAlbum(Map<String, dynamic> data) async {
    try {
      final remoteData = await _remoteDataSource.createAlbum(data);
      return Right(remoteData);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to create album.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> updateAlbum(String id, Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.updateAlbum(id, data);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to update album.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteAlbum(String id) async {
    try {
      await _remoteDataSource.deleteAlbum(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to delete album.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
