import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/artist_repository.dart';
import '../models/artist_model.dart';
import '../sources/artist_remote_data_source.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistRemoteDataSource _remoteDataSource;

  ArtistRepositoryImpl(this._remoteDataSource);

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
  Future<Either<String, List<ArtistModel>>> getArtists({String? tag}) async {
    try {
      final remoteData = await _remoteDataSource.getArtists(tag: tag);
      return Right(remoteData);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to get artists.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, ArtistModel>> getArtistById(String id) async {
    try {
      final remoteData = await _remoteDataSource.getArtistById(id);
      return Right(remoteData);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to get artist.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, ArtistModel>> createArtist(Map<String, dynamic> data) async {
    try {
      final remoteData = await _remoteDataSource.createArtist(data);
      return Right(remoteData);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to create artist.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> updateArtist(String id, Map<String, dynamic> data) async {
    try {
      await _remoteDataSource.updateArtist(id, data);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to update artist.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }

  @override
  Future<Either<String, void>> deleteArtist(String id) async {
    try {
      await _remoteDataSource.deleteArtist(id);
      return const Right(null);
    } on DioException catch (e) {
      return Left(_resolveDioErrorMessage(e.response?.data, 'Failed to delete artist.'));
    } catch (e) {
      return Left('Error: $e');
    }
  }
}
