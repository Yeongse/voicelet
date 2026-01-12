import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/follow_models.dart';
import '../services/follow_api_service.dart';
import '../../home/providers/home_providers.dart';

/// フォローAPIサービスプロバイダー
final followApiServiceProvider = Provider((ref) => FollowApiService());

/// ユーザーのフォロー状態を管理するNotifier
class UserFollowStatusNotifier extends StateNotifier<Map<String, FollowStatus>> {
  final FollowApiService _service;
  final Ref _ref;

  UserFollowStatusNotifier(this._service, this._ref) : super({});

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
      // 関連するリストを更新
      _invalidateRelatedProviders();
      return true;
    } catch (e) {
      // 失敗時は元に戻す
      state = {...state, userId: previousStatus};
      rethrow;
    }
  }

  /// アンフォロー操作（オプティミスティック更新）
  /// currentUserIdを渡すと、そのユーザーのフォロー中リストからも楽観的に削除される
  Future<bool> unfollow(String userId, {String? currentUserId}) async {
    final previousStatus = state[userId] ?? FollowStatus.following;

    // オプティミスティック更新
    state = {...state, userId: FollowStatus.none};

    // ローカルキャッシュからも削除
    if (currentUserId != null) {
      _ref.read(followingListCacheProvider.notifier).removeUser(currentUserId, userId);
      // フォロー数の調整
      final current = _ref.read(followCountDeltaProvider);
      final existing = current[currentUserId] ?? (followingDelta: 0, followersDelta: 0);
      _ref.read(followCountDeltaProvider.notifier).state = {
        ...current,
        currentUserId: (
          followingDelta: existing.followingDelta - 1,
          followersDelta: existing.followersDelta,
        ),
      };
    }

    try {
      await _service.unfollow(userId);
      // 関連するリストを更新
      _invalidateRelatedProviders();
      return true;
    } catch (e) {
      // 失敗時は元に戻す
      state = {...state, userId: previousStatus};
      // キャッシュも元に戻す必要があるが、複雑になるのでinvalidateで対応
      _invalidateRelatedProviders();
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
      // 関連するリストを更新
      _invalidateRelatedProviders();
      return true;
    } catch (e) {
      // 失敗時は元に戻す
      state = {...state, userId: previousStatus};
      rethrow;
    }
  }

  /// フォロー関連のプロバイダーを再取得
  void _invalidateRelatedProviders() {
    // ホーム画面のストーリーリストとおすすめリスト
    _ref.invalidate(storiesProvider);
    _ref.invalidate(discoverProvider);
    // フォロー中/フォロワーリストはfamilyプロバイダーなので個別にinvalidateできない
    // 画面遷移時に再取得される
  }
}

/// ユーザーフォロー状態プロバイダー
final userFollowStatusProvider =
    StateNotifierProvider<UserFollowStatusNotifier, Map<String, FollowStatus>>((ref) {
  final service = ref.watch(followApiServiceProvider);
  return UserFollowStatusNotifier(service, ref);
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

/// フォロー中ユーザーのローカルキャッシュ（楽観的更新用）
/// key: userId, value: そのユーザーがフォローしているユーザーリスト
class FollowingListNotifier extends StateNotifier<Map<String, List<UserWithFollowStatus>>> {
  FollowingListNotifier() : super({});

  /// リストを設定（API取得時）
  void setList(String userId, List<UserWithFollowStatus> users) {
    state = {...state, userId: users};
  }

  /// ユーザーを楽観的に削除
  void removeUser(String ownerId, String targetUserId) {
    final list = state[ownerId];
    if (list == null) return;

    state = {
      ...state,
      ownerId: list.where((u) => u.id != targetUserId).toList(),
    };
  }

  /// リストをクリア
  void clear(String userId) {
    final newState = Map<String, List<UserWithFollowStatus>>.from(state);
    newState.remove(userId);
    state = newState;
  }
}

final followingListCacheProvider =
    StateNotifierProvider<FollowingListNotifier, Map<String, List<UserWithFollowStatus>>>((ref) {
  return FollowingListNotifier();
});

/// フォロワーのローカルキャッシュ（楽観的更新用）
class FollowersListNotifier extends StateNotifier<Map<String, List<UserWithFollowStatus>>> {
  FollowersListNotifier() : super({});

  void setList(String userId, List<UserWithFollowStatus> users) {
    state = {...state, userId: users};
  }

  void removeUser(String ownerId, String targetUserId) {
    final list = state[ownerId];
    if (list == null) return;

    state = {
      ...state,
      ownerId: list.where((u) => u.id != targetUserId).toList(),
    };
  }

  void clear(String userId) {
    final newState = Map<String, List<UserWithFollowStatus>>.from(state);
    newState.remove(userId);
    state = newState;
  }
}

final followersListCacheProvider =
    StateNotifierProvider<FollowersListNotifier, Map<String, List<UserWithFollowStatus>>>((ref) {
  return FollowersListNotifier();
});

/// フォロー数の調整値（楽観的更新用）
/// key: userId, value: (followingDelta, followersDelta)
final followCountDeltaProvider =
    StateProvider<Map<String, ({int followingDelta, int followersDelta})>>((ref) => {});

/// フォロー数の調整を追加
void adjustFollowCount(WidgetRef ref, String userId, {int followingDelta = 0, int followersDelta = 0}) {
  final current = ref.read(followCountDeltaProvider);
  final existing = current[userId] ?? (followingDelta: 0, followersDelta: 0);
  ref.read(followCountDeltaProvider.notifier).state = {
    ...current,
    userId: (
      followingDelta: existing.followingDelta + followingDelta,
      followersDelta: existing.followersDelta + followersDelta,
    ),
  };
}

/// フォロー数の調整をリセット
void resetFollowCountDelta(WidgetRef ref, String userId) {
  final current = ref.read(followCountDeltaProvider);
  final newState = Map<String, ({int followingDelta, int followersDelta})>.from(current);
  newState.remove(userId);
  ref.read(followCountDeltaProvider.notifier).state = newState;
}
