import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/home_models.dart';
import '../services/home_api_service.dart';
import '../../auth/providers/auth_provider.dart';

final homeApiServiceProvider = Provider((ref) => HomeApiService());

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
    hasUnviewed: response.stories.any((s) => !s.isViewed),
  );
});
