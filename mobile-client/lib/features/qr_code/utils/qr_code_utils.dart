/// QRコードのパース結果
class QrCodeParseResult {
  final bool isValid;
  final String? userId;

  const QrCodeParseResult({
    required this.isValid,
    this.userId,
  });
}

/// QRコード関連のユーティリティ
class QrCodeUtils {
  QrCodeUtils._();

  /// VoiceletユーザーQRコードのプレフィックス
  static const String qrPrefix = 'voicelet://user/';

  /// QRコードデータをパースしてユーザーIDを抽出する
  ///
  /// 有効なQRコード形式: voicelet://user/{userId}
  static QrCodeParseResult parseQrCode(String rawValue) {
    if (rawValue.isEmpty) {
      return const QrCodeParseResult(isValid: false);
    }

    if (!rawValue.startsWith(qrPrefix)) {
      return const QrCodeParseResult(isValid: false);
    }

    final userId = rawValue.substring(qrPrefix.length);
    if (userId.isEmpty) {
      return const QrCodeParseResult(isValid: false);
    }

    return QrCodeParseResult(isValid: true, userId: userId);
  }

  /// ユーザーIDからQRコードデータを生成する
  static String generateQrData(String userId) {
    return '$qrPrefix$userId';
  }

  /// スキャンしたQRコードが自分自身のものかどうかを判定する
  static bool isOwnQrCode(String qrData, String currentUserId) {
    final result = parseQrCode(qrData);
    if (!result.isValid) {
      return false;
    }
    return result.userId == currentUserId;
  }
}
