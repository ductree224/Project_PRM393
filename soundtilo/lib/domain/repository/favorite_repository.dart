import 'package:dartz/dartz.dart';

abstract class FavoriteRepository {
  Future<Either<String, List<String>>> getFavorites({int page = 1, int pageSize = 20});
  Future<Either<String, bool>> toggleFavorite(String trackExternalId);
  Future<Either<String, bool>> isFavorite(String trackExternalId);
}
