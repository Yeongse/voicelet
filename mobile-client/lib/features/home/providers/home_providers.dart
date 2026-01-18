import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_models.dart';
import '../services/home_api_service.dart';
import '../../auth/providers/auth_provider.dart';

final homeApiServiceProvider = Provider((ref) => HomeApiService());

/// セッション中に視聴したストーリーIDを追跡
/// 個別のストーリー視聴状態をリアルタイムに追跡するために使用
final viewedStoryIdsProvider = StateProvider<Set<String>>((ref) => {});

/// セッション中に全投稿を視聴済みになったユーザーIDを追跡
/// リストが更新されるまでの間、グレー枠で表示するために使用
final viewedUserIdsProvider = StateProvider<Set<String>>((ref) => {});

/// フォロー中ユーザーのストーリー
/// keepAlive()を使用してタブ切り替え時のちらつきを防止
final storiesProvider = FutureProvider<List<UserStory>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final apiService = ref.read(homeApiServiceProvider);
  final response = await apiService.getStories(userId: userId);
  return response.data;
});

/// 自分のWhisper一覧
final myWhispersProvider = FutureProvider.autoDispose<List<MyWhisper>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final apiService = ref.read(homeApiServiceProvider);
  return apiService.getMyWhispers(userId: userId);
});

/// おすすめユーザー一覧
/// keepAlive()を使用してタブ切り替え時のちらつきを防止
final discoverProvider = FutureProvider<List<DiscoverUser>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];

  final apiService = ref.read(homeApiServiceProvider);
  final response = await apiService.getDiscover(userId: userId);
  return response.data;
});

/// おすすめユーザーのストーリー（targetUserIdで取得）
final discoverUserStoriesProvider = FutureProvider.autoDispose
    .family<UserStory?, String>((ref, targetUserId) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final apiService = ref.read(homeApiServiceProvider);
  final response = await apiService.getDiscoverUserStories(
    userId: userId,
    targetUserId: targetUserId,
  );

  if (response.user == null || response.stories.isEmpty) return null;

  return UserStory(
    user: response.user!,
    stories: response.stories,
  );
});

/// ストーリーの閲覧者一覧（whisperId別）
final viewersProvider = FutureProvider.autoDispose
    .family<ViewersResponse, String>((ref, whisperId) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const ViewersResponse(data: [], totalCount: 0);
  }

  final apiService = ref.read(homeApiServiceProvider);
  return apiService.getViewers(whisperId: whisperId, userId: userId);
});

/// ストーリー削除の状態管理
class DeleteWhisperNotifier extends StateNotifier<AsyncValue<void>> {
  DeleteWhisperNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<bool> deleteWhisper(String whisperId) async {
    state = const AsyncValue.loading();

    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) {
      state = AsyncValue.error('ユーザーが見つかりません', StackTrace.current);
      return false;
    }

    try {
      final apiService = _ref.read(homeApiServiceProvider);
      await apiService.deleteWhisper(whisperId: whisperId, userId: userId);
      state = const AsyncValue.data(null);
      // 削除成功後、myWhispersProviderをリフレッシュ
      _ref.invalidate(myWhispersProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final deleteWhisperProvider =
    StateNotifierProvider<DeleteWhisperNotifier, AsyncValue<void>>((ref) {
  return DeleteWhisperNotifier(ref);
});
