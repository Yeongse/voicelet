import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/follow_models.dart';
import '../services/follow_api_service.dart';
import '../../home/providers/home_providers.dart';

/// フォローAPIサービスプロバイダー
final followApiServiceProvider = Provider((ref) => FollowApiService());

/// ユーザーのフォロー状態を管理するNotifier
class UserFollowStatusNotifier extends StateNotifier<Map<String, UserFollowState>> {
  final FollowApiService _service;
  final Ref _ref;

  UserFollowStatusNotifier(this._service, this._ref) : super({});

  /// フォロー状態を設定
  void setStatus(String userId, FollowStatus status, {String? requestId}) {
    state = {...state, userId: UserFollowState(status: status, requestId: requestId)};
  }

  /// フォロー操作（オプティミスティック更新）
  /// targetUserIdのフォロワー数も楽観的に更新する
  Future<bool> follow(String userId) async {
    final previousState = state[userId] ?? const UserFollowState(status: FollowStatus.none);

    try {
      final result = await _service.follow(userId);

      if (result.isFollowed) {
        state = {...state, userId: const UserFollowState(status: FollowStatus.following)};
        // フォロー成功時、対象ユーザーのフォロワー数を+1
        _adjustTargetUserFollowerCount(userId, 1);
        // 対象ユーザーのフォロワーリストをinvalidate
        _ref.invalidate(followersListProvider((userId: userId, page: 1)));
      } else {
        // リクエスト時はrequestIdも保存
        state = {...state, userId: UserFollowState(status: FollowStatus.requested, requestId: result.requestId)};
        // リクエスト時はフォロワー数は変わらない
      }
      // 関連するリストを更新
      _invalidateRelatedProviders();
      return true;
    } catch (e) {
      // 失敗時は元に戻す
      state = {...state, userId: previousState};
      rethrow;
    }
  }

  /// 対象ユーザーのフォロワー数を楽観的に調整
  void _adjustTargetUserFollowerCount(String targetUserId, int delta) {
    final current = _ref.read(followCountDeltaProvider);
    final existing = current[targetUserId] ?? (followingDelta: 0, followersDelta: 0);
    _ref.read(followCountDeltaProvider.notifier).state = {
      ...current,
      targetUserId: (
        followingDelta: existing.followingDelta,
        followersDelta: existing.followersDelta + delta,
      ),
    };
  }

  /// アンフォロー操作（オプティミスティック更新）
  /// currentUserIdを渡すと、そのユーザーのフォロー中リストからも楽観的に削除される
  Future<bool> unfollow(String userId, {String? currentUserId}) async {
    final previousState = state[userId] ?? const UserFollowState(status: FollowStatus.following);

    // オプティミスティック更新
    state = {...state, userId: const UserFollowState(status: FollowStatus.none)};

    // 対象ユーザーのフォロワー数を-1
    _adjustTargetUserFollowerCount(userId, -1);

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
      // 対象ユーザーのフォロワーリストをinvalidate
      _ref.invalidate(followersListProvider((userId: userId, page: 1)));
      // 関連するリストを更新
      _invalidateRelatedProviders();
      return true;
    } catch (e) {
      // 失敗時は元に戻す
      state = {...state, userId: previousState};
      // 対象ユーザーのフォロワー数も元に戻す
      _adjustTargetUserFollowerCount(userId, 1);
      // キャッシュも元に戻す必要があるが、複雑になるのでinvalidateで対応
      _invalidateRelatedProviders();
      rethrow;
    }
  }

  /// リクエスト取消（userIdからrequestIdを取得して実行）
  Future<bool> cancelRequest(String userId) async {
    final previousState = state[userId] ?? const UserFollowState(status: FollowStatus.requested);
    final requestId = previousState.requestId;

    if (requestId == null) {
      throw Exception('requestId is not available');
    }

    // オプティミスティック更新
    state = {...state, userId: const UserFollowState(status: FollowStatus.none)};

    try {
      await _service.cancelRequest(requestId);
      // 関連するリストを更新
      _invalidateRelatedProviders();
      return true;
    } catch (e) {
      // 失敗時は元に戻す
      state = {...state, userId: previousState};
      rethrow;
    }
  }

  /// フォロー関連のプロバイダーを再取得
  void _invalidateRelatedProviders() {
    // ホーム画面のストーリーリストとおすすめリスト
    _ref.invalidate(storiesProvider);
    _ref.invalidate(discoverProvider);
    // フォロワーリストは各操作メソッド内で個別にinvalidate済み
  }
}

/// ユーザーフォロー状態プロバイダー
final userFollowStatusProvider =
    StateNotifierProvider<UserFollowStatusNotifier, Map<String, UserFollowState>>((ref) {
  final service = ref.watch(followApiServiceProvider);
  return UserFollowStatusNotifier(service, ref);
});

/// フォロー中ユーザー一覧プロバイダー
/// autoDisposeを使用して、画面から離れたらキャッシュを破棄
final followingListProvider =
    FutureProvider.autoDispose.family<UserListResponse, ({String userId, int page})>(
  (ref, params) async {
    final service = ref.watch(followApiServiceProvider);
    return service.getFollowing(params.userId, page: params.page);
  },
);

/// フォロワー一覧プロバイダー
/// autoDisposeを使用して、画面から離れたらキャッシュを破棄
final followersListProvider =
    FutureProvider.autoDispose.family<UserListResponse, ({String userId, int page})>(
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
