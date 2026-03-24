import 'package:dio/dio.dart';
import '../../core/constants/api_urls.dart';
import '../models/album_model.dart';

abstract class AlbumRemoteDataSource {
  Future<List<AlbumModel>> getAlbums({String? tag, String? artistId});
  Future<AlbumModel> getAlbumById(String id, {bool includeTracks = false});
  Future<void> addTrack(String albumId, String trackExternalId, int position);
  Future<void> removeTrack(String albumId, String trackExternalId);
  Future<AlbumModel> createAlbum(Map<String, dynamic> data);
  Future<void> updateAlbum(String id, Map<String, dynamic> data);
  Future<void> deleteAlbum(String id);
}

class AlbumRemoteDataSourceImpl implements AlbumRemoteDataSource {
  final Dio dio;

  AlbumRemoteDataSourceImpl(this.dio);

  @override
  Future<List<AlbumModel>> getAlbums({String? tag, String? artistId}) async {
    final queryParams = <String, dynamic>{};
    if (tag != null) queryParams['tag'] = tag;
    if (artistId != null) queryParams['artistId'] = artistId;
    
    final response = await dio.get(ApiUrls.albums, queryParameters: queryParams.isNotEmpty ? queryParams : null);
    if (response.statusCode == 200) {
      return (response.data as List).map((x) => AlbumModel.fromJson(x)).toList();
    } else {
      throw Exception('Failed to load albums');
    }
  }

  @override
  Future<AlbumModel> getAlbumById(String id, {bool includeTracks = false}) async {
    final response = await dio.get(
      '${ApiUrls.albums}/$id',
      queryParameters: includeTracks ? {'includeTracks': true} : null,
    );
    if (response.statusCode == 200) {
      return AlbumModel.fromJson(response.data);
    } else {
      throw Exception('Failed to load album');
    }
  }

  @override
  Future<void> addTrack(String albumId, String trackExternalId, int position) async {
    final response = await dio.post(
      '${ApiUrls.albums}/$albumId/tracks',
      data: {
        'trackExternalId': trackExternalId,
        'position': position,
      },
    );
    if (response.statusCode != 204 && response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add track to album');
    }
  }

  @override
  Future<void> removeTrack(String albumId, String trackExternalId) async {
    final response = await dio.delete('${ApiUrls.albums}/$albumId/tracks/$trackExternalId');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to remove track from album');
    }
  }

  @override
  Future<AlbumModel> createAlbum(Map<String, dynamic> data) async {
    final response = await dio.post(ApiUrls.albums, data: data);
    if (response.statusCode == 201 || response.statusCode == 200) {
      return AlbumModel.fromJson(response.data);
    } else {
      throw Exception('Failed to create album');
    }
  }

  @override
  Future<void> updateAlbum(String id, Map<String, dynamic> data) async {
    final response = await dio.put('${ApiUrls.albums}/$id', data: data);
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to update album');
    }
  }

  @override
  Future<void> deleteAlbum(String id) async {
    final response = await dio.delete('${ApiUrls.albums}/$id');
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete album');
    }
  }
}
