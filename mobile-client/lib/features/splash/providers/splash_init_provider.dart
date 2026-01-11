import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/api/api_client.dart';
import '../models/splash_result.dart';

/// 最低表示時間（ブランド認知確保）
const splashMinDisplayDuration = Duration(milliseconds: 1500);

/// タイムアウト時間（ユーザー離脱防止）
const splashTimeoutDuration = Duration(seconds: 10);

/// スプラッシュ初期化プロバイダー
///
/// 最低表示時間を確保しつつ認証状態とDB登録状態を確認し、
/// - 認証済み＋登録済み → ホーム
/// - 認証済み＋未登録 → オンボーディング
/// - 未認証 → ログイン
final splashInitProvider = FutureProvider<SplashResult>((ref) async {
  try {
    // 最低表示時間を確保
    await Future.delayed(splashMinDisplayDuration);

    // 認証状態を確認
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
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
      } catch (e) {
        // API呼び出し失敗時はオンボーディングへ（安全側に倒す）
        return const SplashNeedsOnboarding();
      }
    } else {
      // 未認証
      return const SplashUnauthenticated();
    }
  } on TimeoutException {
    return const SplashTimeout();
  } catch (e) {
    return SplashNetworkError(e.toString());
  }
});
