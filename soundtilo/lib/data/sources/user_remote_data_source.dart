import 'package:dio/dio.dart';
import 'package:soundtilo/core/constants/api_urls.dart';
import 'package:soundtilo/data/models/user_model.dart';
import 'package:path/path.dart' as p;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http_parser/http_parser.dart';

class UserRemoteDataSource {
  final Dio _dio;

  UserRemoteDataSource(this._dio);

  Future<UserModel> getProfile() async {
    final response = await _dio.get(ApiUrls.userProfile);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> updateProfile({
    String? displayName,
    String? avatarUrl,
    String? bio,
    DateTime? birthday,
    String? gender,
    String? pronouns,
    bool? isProfilePublic,
    String? statusMessage,
    bool? allowComments,
    bool? allowMessages,
    String? followerPrivacyMode,
  }) async {
    final response = await _dio.put(
      ApiUrls.userProfile,
      data: {
        if (displayName != null) 'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (bio != null) 'bio': bio,
        if (birthday != null) 'birthday': birthday.toIso8601String(),
        if (gender != null) 'gender': gender,
        if (pronouns != null) 'pronouns': pronouns,
        if (isProfilePublic != null) 'isProfilePublic': isProfilePublic,
        if (statusMessage != null) 'statusMessage': statusMessage,
        if (allowComments != null) 'allowComments': allowComments,
        if (allowMessages != null) 'allowMessages': allowMessages,
        if (followerPrivacyMode != null)
          'followerPrivacyMode': followerPrivacyMode,
      },
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// `file` may be a local file path (`String`) or raw bytes (`Uint8List`) (used on web).
  Future<String> uploadAvatar(Object file) async {
    FormData form;

    if (file is Uint8List) {
      // Web path: use bytes
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final multipart = MultipartFile.fromBytes(
        file,
        filename: fileName,
        contentType: MediaType('image', 'jpeg'),
      );
      form = FormData.fromMap({'file': multipart});
    } else if (file is String) {
      final fileName = p.basename(file);
      form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file, filename: fileName),
      });
    } else {
      throw ArgumentError('Unsupported file type for upload');
    }

    final response = await _dio.post(
      '${ApiUrls.userProfile}/avatar',
      data: form,
      options: Options(
        headers: {Headers.contentTypeHeader: 'multipart/form-data'},
      ),
    );

    final data = response.data;
    if (data is Map && data['url'] != null) return data['url'] as String;
    throw Exception('Invalid upload response');
  }
}
