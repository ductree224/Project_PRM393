import '../../data/models/artist_model.dart';
import 'package:dartz/dartz.dart';

abstract class ArtistRepository {
  Future<Either<String, List<ArtistModel>>> getArtists({String? tag});
  Future<Either<String, ArtistModel>> getArtistById(String id);
  Future<Either<String, ArtistModel>> createArtist(Map<String, dynamic> data);
  Future<Either<String, void>> updateArtist(String id, Map<String, dynamic> data);
  Future<Either<String, void>> deleteArtist(String id);
}
