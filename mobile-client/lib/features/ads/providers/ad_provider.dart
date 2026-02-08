import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reward_ad_status.dart';
import '../services/ad_service.dart';
import '../services/reward_ad_api_service.dart';

/// AdService インスタンスプロバイダー
final adServiceProvider = Provider<AdService>((ref) => AdService.instance);

/// RewardAdApiService プロバイダー
final rewardAdApiServiceProvider = Provider((ref) => RewardAdApiService());

/// リワード広告ステータスプロバイダー
final rewardAdStatusProvider =
    StateNotifierProvider<RewardAdStatusNotifier, AsyncValue<RewardAdStatus>>(
  (ref) => RewardAdStatusNotifier(ref),
);

class RewardAdStatusNotifier extends StateNotifier<AsyncValue<RewardAdStatus>> {
  RewardAdStatusNotifier(this._ref) : super(const AsyncValue.loading()) {
    fetchStatus();
  }

  final Ref _ref;

  /// ステータスを取得
  Future<void> fetchStatus() async {
    // 既にデータがある場合は静かに更新（ローディング状態を表示しない）
    final hasData = state.valueOrNull != null;
    if (!hasData) {
      state = const AsyncValue.loading();
    }
    try {
      final apiService = _ref.read(rewardAdApiServiceProvider);
      final status = await apiService.getStatus();
      state = AsyncValue.data(status);
    } catch (e, st) {
      // エラー時は既存のデータがあればそれを維持
      if (!hasData) {
        state = AsyncValue.error(e, st);
      }
    }
  }

  /// リワード広告を使用して履歴をクリア
  Future<RewardAdUseResponse?> useReward() async {
    try {
      final apiService = _ref.read(rewardAdApiServiceProvider);
      final response = await apiService.useReward();

      // ステータスを更新
      state = AsyncValue.data(
        RewardAdStatus(
          remainingCount: response.remainingCount,
          nextResetAt: response.nextResetAt,
          todayClearedCount: response.clearedCount,
        ),
      );

      return response;
    } catch (e) {
      // エラー時はステータスを再取得
      await fetchStatus();
      rethrow;
    }
  }
}

/// リワード広告の読み込み状態プロバイダー
final rewardedAdStateProvider = StreamProvider<RewardedAdState>((ref) {
  final adService = ref.watch(adServiceProvider);
  return adService.rewardedAdState;
});

/// リワード広告が利用可能かどうか
final isRewardedAdReadyProvider = Provider<bool>((ref) {
  final adService = ref.watch(adServiceProvider);
  return adService.isRewardedAdReady;
});
