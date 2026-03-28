import 'package:dio/dio.dart';
import '../../core/constants/api_urls.dart';
import '../models/artist_model.dart';

abstract class ArtistRemoteDataSource {
  Future<List<ArtistModel>> getArtists({String? tag});
  Future<ArtistModel> getArtistById(String id);
  Future<ArtistModel> createArtist(Map<String, dynamic> data);
  Future<void> updateArtist(String id, Map<String, dynamic> data);
  Future<void> deleteArtist(String id);
}

class ArtistRemoteDataSourceImpl implements ArtistRemoteDataSource {
  final Dio dio;

  ArtistRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ArtistModel>> getArtists({String? tag}) async {
    final response = await dio.get(ApiUrls.artists, queryParameters: tag != null ? {'tag': tag} : null);
    if (response.statusCode == 200) {
      return (response.data as List).map((x) => ArtistModel.fromJson(x)).toList();
    } else {
      throw Exception('Failed to load artists');
    }
  }

  @override
  Future<ArtistModel> getArtistById(String id) async {
    final response = await dio.get('${ApiUrls.artists}/$id');
    if (response.statusCode == 200) {
      return ArtistModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load artist');
    }
  }

  @override
  Future<ArtistModel> createArtist(Map<String, dynamic> data) async {
    final response = await dio.post(ApiUrls.artists, data: data);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return ArtistModel.fromJson(response.data);
    } else {
      throw Exception('Failed to create artist');
    }
  }

  @override
  Future<void> updateArtist(String id, Map<String, dynamic> data) async {
    final response = await dio.put('${ApiUrls.artists}/$id', data: data);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to update artist');
    }
  }

  @override
  Future<void> deleteArtist(String id) async {
    final response = await dio.delete('${ApiUrls.artists}/$id');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete artist');
    }
  }
}
