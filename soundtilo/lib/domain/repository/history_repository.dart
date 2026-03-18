import 'package:dartz/dartz.dart';

abstract class HistoryRepository {
  Future<Either<String, List<Map<String, dynamic>>>> getHistory({
    int page = 1,
    int pageSize = 20,
  });
  Future<Either<String, void>> recordListen({
    required String trackExternalId,
    required int durationListened,
    required bool completed,
  });
  Future<Either<String, int>> deleteHistory(List<String> historyIds);
}
