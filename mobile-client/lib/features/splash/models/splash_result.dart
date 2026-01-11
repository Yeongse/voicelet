/// スプラッシュ初期化の結果型
sealed class SplashResult {
  const SplashResult();
}

/// 初期化成功（認証済み＋プロフィール登録済み）
class SplashSuccess extends SplashResult {
  const SplashSuccess();
}

/// 認証済みだがプロフィール未登録（オンボーディングが必要）
class SplashNeedsOnboarding extends SplashResult {
  const SplashNeedsOnboarding();
}

/// 未認証
class SplashUnauthenticated extends SplashResult {
  const SplashUnauthenticated();
}

/// タイムアウト
class SplashTimeout extends SplashResult {
  const SplashTimeout();
}

/// ネットワークエラー
class SplashNetworkError extends SplashResult {
  final String message;
  const SplashNetworkError(this.message);
}
