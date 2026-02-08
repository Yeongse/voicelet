import 'dart:io';

/// AdMob 広告ID管理クラス
/// 環境（開発/本番）に応じた広告IDを提供する
class AdConfig {
  AdConfig._();

  /// 本番環境かどうか（dart-define で設定）
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false,
  );

  /// AdMob App ID（ネイティブ設定用、参照のみ）
  /// Note: Android/iOS のネイティブ設定も本番用に更新が必要
  static String get appId {
    if (isProduction) {
      return 'ca-app-pub-6257323478670896~YYYYY'; // TODO: AdMobコンソールでApp IDを確認
    }
    // Test App IDs
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544~3347511713'
        : 'ca-app-pub-3940256099942544~1458002511';
  }

  /// バナー広告ユニットID
  static String get bannerAdUnitId {
    if (isProduction) {
      return 'ca-app-pub-6257323478670896/8962942447';
    }
    // Test Ad Unit IDs
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111'
        : 'ca-app-pub-3940256099942544/2934735716';
  }

  /// リワード広告ユニットID
  static String get rewardedAdUnitId {
    if (isProduction) {
      return 'ca-app-pub-6257323478670896/6819887038';
    }
    // Test Ad Unit IDs
    return Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/5224354917'
        : 'ca-app-pub-3940256099942544/1712485313';
  }

  /// 1日あたりのリワード広告使用回数上限
  static const int dailyRewardLimit = 3;

  /// リワード広告リセット時刻（JST午前5時）
  static const int resetHourJst = 5;
}
