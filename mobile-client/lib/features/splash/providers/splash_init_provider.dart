import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/api_client.dart';
import '../../ads/services/ad_service.dart';
import '../models/splash_result.dart';

/// 最低表示時間（ブランド認知確保）
const splashMinDisplayDuration = Duration(milliseconds: 1500);

/// タイムアウト時間（ユーザー離脱防止）
const splashTimeoutDuration = Duration(seconds: 10);

/// トークン期限切れマージン（秒）
/// gotrue-dart の expiryMargin と同じ値を使用し、
/// 期限切れ直前のトークンでAPI呼び出しが失敗するのを防ぐ
const _tokenExpiryMarginSeconds = 60;

/// スプラッシュ初期化プロバイダー
///
/// 最低表示時間を確保しつつ認証状態とDB登録状態を確認し、
/// - 認証済み＋登録済み → ホーム
/// - 認証済み＋未登録 → オンボーディング
/// - 未認証 → ログイン
final splashInitProvider = FutureProvider<SplashResult>((ref) async {
  try {
    // AdMob SDK 初期化を並行して実行
    final adInitFuture = AdService.instance.initialize().then((_) {
      // 初期化完了後にリワード広告をプリロード
      AdService.instance.preloadRewardedAd();
    });

    // 最低表示時間を確保（AdMob初期化と並行）
    await Future.wait([
      Future.delayed(splashMinDisplayDuration),
      adInitFuture,
    ]);

    // 認証状態を確認
    var session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      return const SplashUnauthenticated();
    }

    // Supabase.initialize() はトークンリフレッシュを await しないため、
    // ストレージから読み込まれた期限切れトークンがそのままセットされている可能性がある。
    // （特に iOS の OOM kill 時に NSUserDefaults のフラッシュ前にプロセスが終了すると、
    //   リフレッシュ後の新しいトークンが失われ、古い期限切れトークンが残る）
    // 期限切れまたは期限切れ間近の場合、明示的にリフレッシュして有効なトークンを確保する。
    final expiresAt = session.expiresAt;
    final needsRefresh = expiresAt != null &&
        DateTime.now().isAfter(
          DateTime.fromMillisecondsSinceEpoch(
            (expiresAt - _tokenExpiryMarginSeconds) * 1000,
          ),
        );

    if (needsRefresh) {
      try {
        final response =
            await Supabase.instance.client.auth.refreshSession();
        if (response.session == null) {
          return const SplashUnauthenticated();
        }
        session = response.session!;
      } catch (e) {
        // リフレッシュ失敗（リフレッシュトークン無効、ネットワークエラー等）
        // → セッションが無効なため再ログインが必要
        return const SplashUnauthenticated();
      }
    }

    // 認証済みの場合、バックエンドでDB登録状態を確認
    try {
      final response = await ApiClient().dio.post(
        '/api/auth/callback',
        data: {'accessToken': session.accessToken},
      );

      final data = response.data as Map<String, dynamic>;
      final isRegistered = data['isRegistered'] as bool;

      if (isRegistered) {
        return const SplashSuccess();
      } else {
        return const SplashNeedsOnboarding();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // トークンがサーバーに拒否された → 再ログインが必要
        return const SplashUnauthenticated();
      }
      // ネットワークエラー、タイムアウト、サーバーエラー等
      return SplashNetworkError(e.message ?? 'ネットワークエラー');
    }
  } on TimeoutException {
    return const SplashTimeout();
  } catch (e) {
    return SplashNetworkError(e.toString());
  }
});
