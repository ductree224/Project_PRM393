import 'package:dio/dio.dart';

abstract class WaitlistRemoteDataSource {
  Future<Map<String, dynamic>> getWaitlist();
  Future<void> addTrack(String trackExternalId);
  Future<void> removeTrack(String trackExternalId);
  Future<void> reorderTracks(List<String> trackExternalIds);
  Future<void> clearWaitlist();
}

class WaitlistRemoteDataSourceImpl implements WaitlistRemoteDataSource {
  final Dio dio;

  WaitlistRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getWaitlist() async {
    // GET: api/waitlist
    final response = await dio.get('/api/waitlist');
    return response.data;
  }

  @override
  Future<void> addTrack(String trackExternalId) async {
    // POST: api/waitlist/tracks
    await dio.post(
      '/api/waitlist/tracks',
      data: {'trackExternalId': trackExternalId},
    );
  }

  @override
  Future<void> removeTrack(String trackExternalId) async {
    // DELETE: api/waitlist/tracks/{trackExternalId}
    await dio.delete('/api/waitlist/tracks/$trackExternalId');
  }

  @override
  Future<void> reorderTracks(List<String> trackExternalIds) async {
    // PUT: api/waitlist/tracks/reorder
    await dio.put(
      '/api/waitlist/tracks/reorder',
      data: {'trackExternalIds': trackExternalIds},
    );
  }

  @override
  Future<void> clearWaitlist() async {
    // DELETE: api/waitlist
    await dio.delete('/api/waitlist');
  }
}