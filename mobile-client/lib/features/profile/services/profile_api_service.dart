import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../../../core/api/api_client.dart';
import '../../auth/models/profile.dart';

class ProfileApiService {
  final Dio _dio = ApiClient().dio;

  /// 自分のプロフィールを取得
  Future<Profile> getMyProfile() async {
    final response = await _dio.get('/api/profiles/me');
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }

  /// プロフィールを新規登録（ユーザーをDBに永続化）
  Future<Profile> registerProfile({
    required String username,
    required String name,
    String? bio,
    String? birthMonth,
    String? avatarPath,
  }) async {
    final data = <String, dynamic>{
      'username': username,
      'name': name,
    };
    if (bio != null) data['bio'] = bio;
    if (birthMonth != null) data['birthMonth'] = birthMonth;
    if (avatarPath != null) data['avatarPath'] = avatarPath;

    final response = await _dio.post('/api/profiles/me', data: data);
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }

  /// 他ユーザーのプロフィールを取得
  Future<Profile> getUserProfile(String userId) async {
    final response = await _dio.get('/api/profiles/$userId');
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }

  /// プロフィールを更新
  Future<Profile> updateProfile({
    String? username,
    String? name,
    String? bio,
    String? birthMonth,
    String? avatarPath,
    bool? isPrivate,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (name != null) data['name'] = name;
    if (bio != null) data['bio'] = bio;
    if (birthMonth != null) data['birthMonth'] = birthMonth;
    if (avatarPath != null) data['avatarPath'] = avatarPath;
    if (isPrivate != null) data['isPrivate'] = isPrivate;

    final response = await _dio.patch('/api/profiles/me', data: data);
    return Profile.fromJson(response.data as Map<String, dynamic>);
  }

  /// アカウントを削除
  Future<void> deleteAccount() async {
    await _dio.delete('/api/profiles/me');
  }

  /// アバターアップロード用の署名付きURLを取得
  /// fileNameはuuid_timestamp形式で指定
  Future<Map<String, String>> getAvatarUploadUrl({
    required String contentType,
    required int fileSize,
    required String fileName,
  }) async {
    final response = await _dio.post(
      '/api/profiles/me/avatar/upload-url',
      data: {
        'contentType': contentType,
        'fileSize': fileSize,
        'fileName': fileName,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return {
      'uploadUrl': data['uploadUrl'] as String,
      'avatarPath': data['avatarPath'] as String,
      'expiresAt': data['expiresAt'] as String,
    };
  }

  /// Cloud Storageにアバター画像をアップロード
  Future<void> uploadAvatar({
    required String uploadUrl,
    required File imageFile,
    required String contentType,
  }) async {
    final bytes = await imageFile.readAsBytes();
    await http.put(
      Uri.parse(uploadUrl),
      headers: {
        'Content-Type': contentType,
      },
      body: bytes,
    );
  }
}
