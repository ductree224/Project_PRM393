import 'package:dio/dio.dart';
import 'package:soundtilo/domain/entities/track_entity.dart';
import 'package:soundtilo/domain/repository/waitlist_repository.dart';
import 'package:soundtilo/data/sources/waitlist_remote_data_source.dart';

import '../models/track_model.dart';
// QUAN TRỌNG: Import model của Track để mapping từ JSON
// import 'package:soundtilo/data/models/track_model.dart';

class WaitlistRepositoryImpl implements WaitlistRepository {
  final WaitlistRemoteDataSource _remoteDataSource;

  WaitlistRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TrackEntity>> getWaitlist() async {
    try {
      final data = await _remoteDataSource.getWaitlist();

      // Backend C# trả về Waitlist object có chứa mảng 'tracks' bên trong
      final tracksList = (data['tracks'] as List?) ?? [];

      // Chuyển đổi JSON thành TrackEntity (Thay thế TrackModel.fromJson bằng hàm map của dự án anh/chị)
      return tracksList.map((json) => TrackModel.fromJson(json)).toList();


    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Không thể tải danh sách chờ.');
    } catch (e) {
      throw Exception('Đã xảy ra lỗi: $e');
    }
  }

  @override
  Future<void> addTrackToWaitlist(String trackExternalId) async {
    try {
      await _remoteDataSource.addTrack(trackExternalId);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi khi thêm vào danh sách chờ.');
    }
  }

  @override
  Future<void> removeTrackFromWaitlist(String trackExternalId) async {
    try {
      await _remoteDataSource.removeTrack(trackExternalId);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi khi xóa khỏi danh sách chờ.');
    }
  }

  @override
  Future<void> reorderWaitlist(List<String> trackExternalIds) async {
    try {
      await _remoteDataSource.reorderTracks(trackExternalIds);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi khi sắp xếp danh sách chờ.');
    }
  }

  @override
  Future<void> clearWaitlist() async {
    try {
      await _remoteDataSource.clearWaitlist();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi khi dọn dẹp danh sách chờ.');
    }
  }
}