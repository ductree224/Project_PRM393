import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/repository/favorite_repository.dart';

class ToggleFavoriteUseCase {
  final FavoriteRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<Either<String, bool>> call(String trackExternalId) {
    return repository.toggleFavorite(trackExternalId);
  }
}

class GetFavoritesUseCase {
  final FavoriteRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<Either<String, List<String>>> call({int page = 1, int pageSize = 20}) {
    return repository.getFavorites(page: page, pageSize: pageSize);
  }
}

class IsFavoriteUseCase {
  final FavoriteRepository repository;

  IsFavoriteUseCase(this.repository);

  Future<Either<String, bool>> call(String trackExternalId) {
    return repository.isFavorite(trackExternalId);
  }
}
