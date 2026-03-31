import 'package:dartz/dartz.dart';
import 'package:soundtilo/domain/repository/history_repository.dart';

class GetHistoryUseCase {
  final HistoryRepository repository;

  GetHistoryUseCase(this.repository);

  Future<Either<String, List<Map<String, dynamic>>>> call({
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.getHistory(page: page, pageSize: pageSize);
  }
}

class RecordListenUseCase {
  final HistoryRepository repository;

  RecordListenUseCase(this.repository);

  Future<Either<String, void>> call({
    required String trackExternalId,
    required int durationListened,
    required bool completed,
  }) {
    return repository.recordListen(
      trackExternalId: trackExternalId,
      durationListened: durationListened,
      completed: completed,
    );
  }
}

class DeleteHistoryUseCase {
  final HistoryRepository repository;

  DeleteHistoryUseCase(this.repository);

  Future<Either<String, int>> call(List<String> historyIds) {
    return repository.deleteHistory(historyIds);
  }
}
