import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../auth/models/profile.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/profile_api_service.dart';

/// プロフィールAPIサービスプロバイダー
final profileApiServiceProvider = Provider((ref) => ProfileApiService());

/// 自分のプロフィールプロバイダー
final myProfileProvider = FutureProvider<Profile>((ref) async {
  final service = ref.watch(profileApiServiceProvider);
  return service.getMyProfile();
});

/// 他ユーザーのプロフィールプロバイダー（family）
final userProfileProvider = FutureProvider.family<Profile, String>((ref, userId) async {
  final service = ref.watch(profileApiServiceProvider);
  return service.getUserProfile(userId);
});

/// プロフィール更新状態
class ProfileUpdateState {
  final bool isLoading;
  final String? error;
  final Profile? profile;

  const ProfileUpdateState({
    this.isLoading = false,
    this.error,
    this.profile,
  });

  ProfileUpdateState copyWith({
    bool? isLoading,
    String? error,
    Profile? profile,
  }) {
    return ProfileUpdateState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profile: profile ?? this.profile,
    );
  }
}

/// プロフィール更新Notifier
class ProfileUpdateNotifier extends StateNotifier<ProfileUpdateState> {
  final ProfileApiService _service;
  final Ref _ref;

  ProfileUpdateNotifier(this._service, this._ref) : super(const ProfileUpdateState());

  /// プロフィールを更新
  Future<bool> updateProfile({
    String? name,
    String? bio,
    String? birthMonth,
    bool? isPrivate,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final profile = await _service.updateProfile(
        name: name,
        bio: bio,
        birthMonth: birthMonth,
        isPrivate: isPrivate,
      );

      state = state.copyWith(isLoading: false, profile: profile);
      _ref.invalidate(myProfileProvider);
      // authProviderのプロフィールも更新
      _ref.read(authProvider.notifier).updateProfile(profile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// アバター画像をアップロード
  Future<bool> uploadAvatar(XFile imageFile) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Content-Typeを決定
      final extension = imageFile.path.split('.').last.toLowerCase();
      String contentType;
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'png':
          contentType = 'image/png';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        default:
          throw Exception('サポートされていないファイル形式です');
      }

      // ファイルサイズを確認
      final file = File(imageFile.path);
      final fileSize = await file.length();
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('ファイルサイズは5MB以下にしてください');
      }

      // ファイル名を生成（uuid_timestamp形式）
      final uuid = const Uuid().v4();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${uuid}_$timestamp';

      // 署名付きURLを取得
      final urlData = await _service.getAvatarUploadUrl(
        contentType: contentType,
        fileSize: fileSize,
        fileName: fileName,
      );

      // Cloud Storageにアップロード
      await _service.uploadAvatar(
        uploadUrl: urlData['uploadUrl']!,
        imageFile: file,
        contentType: contentType,
      );

      // プロフィールを更新してavatarPathを保存
      final profile = await _service.updateProfile(
        avatarPath: urlData['avatarPath'],
      );

      state = state.copyWith(isLoading: false, profile: profile);
      _ref.invalidate(myProfileProvider);
      // authProviderのプロフィールも更新
      _ref.read(authProvider.notifier).updateProfile(profile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// アカウントを削除
  Future<bool> deleteAccount() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _service.deleteAccount();
      state = state.copyWith(isLoading: false);

      // サインアウト
      await _ref.read(authProvider.notifier).signOut();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// 非公開設定を更新
  Future<bool> updatePrivacy(bool isPrivate) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final profile = await _service.updateProfile(isPrivate: isPrivate);

      state = state.copyWith(isLoading: false, profile: profile);
      _ref.invalidate(myProfileProvider);
      // authProviderのプロフィールも更新
      _ref.read(authProvider.notifier).updateProfile(profile);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

/// プロフィール更新プロバイダー
final profileUpdateProvider =
    StateNotifierProvider<ProfileUpdateNotifier, ProfileUpdateState>((ref) {
  final service = ref.watch(profileApiServiceProvider);
  return ProfileUpdateNotifier(service, ref);
});
