import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import '../config/ad_config.dart';

/// リワード広告の状態
enum RewardedAdState {
  initial,
  loading,
  ready,
  showing,
  completed,
  dismissed,
  failed,
}

/// AdMob SDK ラッパーサービス
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _isInitialized = false;
  RewardedAd? _rewardedAd;

  final _rewardedAdStateController = StreamController<RewardedAdState>.broadcast();

  /// リワード広告の状態ストリーム
  Stream<RewardedAdState> get rewardedAdState => _rewardedAdStateController.stream;

  /// リワード広告がロード済みか
  bool get isRewardedAdReady => _rewardedAd != null;

  /// SDK初期化（起動時に1回呼び出し）
  Future<void> initialize() async {
    if (_isInitialized) return;

    // iOS の場合は ATT 許可を先にリクエスト
    if (Platform.isIOS) {
      await _requestTrackingAuthorization();
    }

    // AdMob SDK 初期化
    await MobileAds.instance.initialize();
    _isInitialized = true;

    debugPrint('[AdService] Initialized');
  }

  /// iOS ATT 許可リクエスト
  Future<void> _requestTrackingAuthorization() async {
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // 少し遅延を入れてからリクエスト（Apple推奨）
        await Future.delayed(const Duration(milliseconds: 500));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('[AdService] ATT request failed: $e');
    }
  }

  /// リワード広告をプリロード
  Future<void> preloadRewardedAd() async {
    if (_rewardedAd != null) {
      debugPrint('[AdService] Rewarded ad already loaded');
      return;
    }

    _rewardedAdStateController.add(RewardedAdState.loading);

    await RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdService] Rewarded ad loaded');
          _rewardedAd = ad;
          _rewardedAdStateController.add(RewardedAdState.ready);
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] Rewarded ad failed to load: ${error.message}');
          _rewardedAd = null;
          _rewardedAdStateController.add(RewardedAdState.failed);
        },
      ),
    );
  }

  /// リワード広告を表示し、視聴完了を待つ
  /// Returns: true if user earned reward, false if dismissed early or failed
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) {
      debugPrint('[AdService] No rewarded ad available');
      _rewardedAdStateController.add(RewardedAdState.failed);
      return false;
    }

    final completer = Completer<bool>();

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdService] Rewarded ad showed');
        _rewardedAdStateController.add(RewardedAdState.showing);
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdService] Rewarded ad dismissed');
        ad.dispose();
        _rewardedAd = null;
        _rewardedAdStateController.add(RewardedAdState.dismissed);

        // 視聴完了していない場合（completer がまだ完了していない場合）
        if (!completer.isCompleted) {
          completer.complete(false);
        }

        // 次の広告をプリロード
        preloadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] Rewarded ad failed to show: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _rewardedAdStateController.add(RewardedAdState.failed);

        if (!completer.isCompleted) {
          completer.complete(false);
        }

        // 次の広告をプリロード
        preloadRewardedAd();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdService] User earned reward: ${reward.amount} ${reward.type}');
        _rewardedAdStateController.add(RewardedAdState.completed);
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      },
    );

    return completer.future;
  }

  /// バナー広告を作成
  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: AdConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  /// リソース解放
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _rewardedAdStateController.close();
  }
}
