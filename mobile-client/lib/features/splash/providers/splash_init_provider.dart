import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/splash_result.dart';
import '../../home/providers/home_data_provider.dart';

/// 最低表示時間（ブランド認知確保）
const splashMinDisplayDuration = Duration(milliseconds: 1500);

/// タイムアウト時間（ユーザー離脱防止）
const splashTimeoutDuration = Duration(seconds: 10);

/// スプラッシュ初期化プロバイダー
///
/// 最低表示時間とデータロードを並行実行し、
/// タイムアウト管理を含む初期化結果を返却する。
final splashInitProvider = FutureProvider<SplashResult>((ref) async {
  try {
    // 最低表示時間とデータロードを並行実行
    await Future.wait([
      Future.delayed(splashMinDisplayDuration),
      ref.read(homeDataProvider.future),
    ]).timeout(
      splashTimeoutDuration,
      onTimeout: () => throw TimeoutException('Splash timeout'),
    );

    return const SplashSuccess();
  } on TimeoutException {
    return const SplashTimeout();
  } catch (e) {
    return SplashNetworkError(e.toString());
  }
});
