import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/repository/waitlist_repository.dart';

class GetWaitlistUseCase {
  final WaitlistRepository repository;

  GetWaitlistUseCase(this.repository);

  Future<List<TrackEntity>> call() async {
    return await repository.getWaitlist();
  }
}

class AddTrackToWaitlistUseCase {
  final WaitlistRepository repository;

  AddTrackToWaitlistUseCase(this.repository);

  Future<void> call(String trackExternalId) async {
    return await repository.addTrackToWaitlist(trackExternalId);
  }
}

class RemoveTrackFromWaitlistUseCase {
  final WaitlistRepository repository;

  RemoveTrackFromWaitlistUseCase(this.repository);

  Future<void> call(String trackExternalId) async {
    return await repository.removeTrackFromWaitlist(trackExternalId);
  }
}

class ReorderWaitlistUseCase {
  final WaitlistRepository repository;

  ReorderWaitlistUseCase(this.repository);

  Future<void> call(List<String> trackExternalIds) async {
    return await repository.reorderWaitlist(trackExternalIds);
  }
}

class ClearWaitlistUseCase {
  final WaitlistRepository repository;

  ClearWaitlistUseCase(this.repository);

  Future<void> call() async {
    return await repository.clearWaitlist();
  }
}