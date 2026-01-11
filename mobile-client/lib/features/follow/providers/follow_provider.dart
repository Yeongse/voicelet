import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/follow_models.dart';
import '../services/follow_api_service.dart';

/// フォローAPIサービスプロバイダー
final followApiServiceProvider = Provider((ref) => FollowApiService());

/// ユーザーのフォロー状態を管理するNotifier
class UserFollowStatusNotifier extends StateNotifier<Map<String, FollowStatus>> {
  final FollowApiService _service;

  UserFollowStatusNotifier(this._service) : super({});

  /// フォロー状態を設定
  void setStatus(String userId, FollowStatus status) {
    state = {...state, userId: status};
  }

  /// フォロー操作（オプティミスティック更新）
  Future<bool> follow(String userId) async {
    final previousStatus = state[userId] ?? FollowStatus.none;

    try {
      final result = await _service.follow(userId);

      if (result.isFollowed) {
        state = {...state, userId: FollowStatus.following};
      } else {
        state = {...state, userId: FollowStatus.requested};
      }
      return true;
    } catch (e) {
      // 失敗時は元に戻す
      state = {...state, userId: previousStatus};
      rethrow;
    }
  }

  /// アンフォロー操作（オプティミスティック更新）
  Future<bool> unfollow(String userId) async {
    final previousStatus = state[userId] ?? FollowStatus.following;

    // オプティミスティック更新
    state = {...state, userId: FollowStatus.none};

    try {
      await _service.unfollow(userId);
      return true;
    } catch (e) {
      // 失敗時は元に戻す
      state = {...state, userId: previousStatus};
      rethrow;
    }
  }

  /// リクエスト取消（requestIdが必要）
  Future<bool> cancelRequest(String userId, String requestId) async {
    final previousStatus = state[userId] ?? FollowStatus.requested;

    // オプティミスティック更新
    state = {...state, userId: FollowStatus.none};

    try {
      await _service.cancelRequest(requestId);
      return true;
    } catch (e) {
      // 失敗時は元に戻す
      state = {...state, userId: previousStatus};
      rethrow;
    }
  }
}

/// ユーザーフォロー状態プロバイダー
final userFollowStatusProvider =
    StateNotifierProvider<UserFollowStatusNotifier, Map<String, FollowStatus>>((ref) {
  final service = ref.watch(followApiServiceProvider);
  return UserFollowStatusNotifier(service);
});

/// フォロー中ユーザー一覧プロバイダー
final followingListProvider = FutureProvider.family<UserListResponse, ({String userId, int page})>(
  (ref, params) async {
    final service = ref.watch(followApiServiceProvider);
    return service.getFollowing(params.userId, page: params.page);
  },
);

/// フォロワー一覧プロバイダー
final followersListProvider = FutureProvider.family<UserListResponse, ({String userId, int page})>(
  (ref, params) async {
    final service = ref.watch(followApiServiceProvider);
    return service.getFollowers(params.userId, page: params.page);
  },
);

/// フォローリクエスト一覧プロバイダー（受信）
final followRequestsProvider = FutureProvider.family<FollowRequestListResponse, int>(
  (ref, page) async {
    final service = ref.watch(followApiServiceProvider);
    return service.getFollowRequests(page: page);
  },
);

/// 送信済みフォローリクエスト一覧プロバイダー
final sentFollowRequestsProvider = FutureProvider.family<SentFollowRequestListResponse, int>(
  (ref, page) async {
    final service = ref.watch(followApiServiceProvider);
    return service.getSentFollowRequests(page: page);
  },
);

/// フォローリクエスト数プロバイダー
final followRequestCountProvider = FutureProvider<int>((ref) async {
  final service = ref.watch(followApiServiceProvider);
  return service.getFollowRequestCount();
});

/// フォローリクエスト操作用Notifier
class FollowRequestNotifier extends StateNotifier<AsyncValue<void>> {
  final FollowApiService _service;
  final Ref _ref;

  FollowRequestNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  /// リクエスト承認
  Future<void> approve(String requestId) async {
    await _service.approveRequest(requestId);
    // カウントのみ更新（一覧はUI側でローカル管理）
    _ref.invalidate(followRequestCountProvider);
  }

  /// リクエスト拒否
  Future<void> reject(String requestId) async {
    await _service.rejectRequest(requestId);
    // カウントのみ更新（一覧はUI側でローカル管理）
    _ref.invalidate(followRequestCountProvider);
  }
}

/// フォローリクエスト操作プロバイダー
final followRequestNotifierProvider =
    StateNotifierProvider<FollowRequestNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(followApiServiceProvider);
  return FollowRequestNotifier(service, ref);
});
