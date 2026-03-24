import 'package:soundtilo/domain/entities/track_entity.dart';

abstract class WaitlistRepository {
  Future<List<TrackEntity>> getWaitlist();
  Future<void> addTrackToWaitlist(String trackExternalId);
  Future<void> removeTrackFromWaitlist(String trackExternalId);
  Future<void> reorderWaitlist(List<String> trackExternalIds);
  Future<void> clearWaitlist();
}