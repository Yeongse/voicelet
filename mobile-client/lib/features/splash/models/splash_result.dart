/// スプラッシュ初期化の結果型
sealed class SplashResult {
  const SplashResult();
}

/// 初期化成功
class SplashSuccess extends SplashResult {
  const SplashSuccess();
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
