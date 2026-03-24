import '../../data/models/album_model.dart';
import 'package:dartz/dartz.dart';

abstract class AlbumRepository {
  Future<Either<String, List<AlbumModel>>> getAlbums({String? tag, String? artistId});
  Future<Either<String, AlbumModel>> getAlbumById(String id);
  Future<Either<String, AlbumModel>> createAlbum(Map<String, dynamic> data);
  Future<Either<String, void>> updateAlbum(String id, Map<String, dynamic> data);
  Future<Either<String, void>> deleteAlbum(String id);
}
