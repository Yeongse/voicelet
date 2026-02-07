import 'package:flutter_test/flutter_test.dart';
import 'package:voicelet/features/qr_code/utils/qr_code_utils.dart';

void main() {
  group('QrCodeUtils', () {
    group('parseQrCode', () {
      test('有効なvoiceletユーザーQRコードをパースできる', () {
        const validQrData = 'voicelet://user/123e4567-e89b-12d3-a456-426614174000';

        final result = QrCodeUtils.parseQrCode(validQrData);

        expect(result.isValid, isTrue);
        expect(result.userId, equals('123e4567-e89b-12d3-a456-426614174000'));
      });

      test('異なるUUID形式も正しくパースできる', () {
        const validQrData = 'voicelet://user/550e8400-e29b-41d4-a716-446655440000';

        final result = QrCodeUtils.parseQrCode(validQrData);

        expect(result.isValid, isTrue);
        expect(result.userId, equals('550e8400-e29b-41d4-a716-446655440000'));
      });

      test('無効なプレフィックスのQRコードを拒否する', () {
        const invalidQrData = 'https://example.com/user/123';

        final result = QrCodeUtils.parseQrCode(invalidQrData);

        expect(result.isValid, isFalse);
        expect(result.userId, isNull);
      });

      test('プレフィックスのみのQRコードを拒否する', () {
        const invalidQrData = 'voicelet://user/';

        final result = QrCodeUtils.parseQrCode(invalidQrData);

        expect(result.isValid, isFalse);
        expect(result.userId, isNull);
      });

      test('空文字列を拒否する', () {
        const invalidQrData = '';

        final result = QrCodeUtils.parseQrCode(invalidQrData);

        expect(result.isValid, isFalse);
        expect(result.userId, isNull);
      });

      test('他のvoiceletスキームを拒否する', () {
        const invalidQrData = 'voicelet://story/123';

        final result = QrCodeUtils.parseQrCode(invalidQrData);

        expect(result.isValid, isFalse);
        expect(result.userId, isNull);
      });

      test('部分一致するURLを拒否する', () {
        const invalidQrData = 'fake-voicelet://user/123';

        final result = QrCodeUtils.parseQrCode(invalidQrData);

        expect(result.isValid, isFalse);
        expect(result.userId, isNull);
      });
    });

    group('generateQrData', () {
      test('ユーザーIDからQRデータを生成できる', () {
        const userId = '123e4567-e89b-12d3-a456-426614174000';

        final qrData = QrCodeUtils.generateQrData(userId);

        expect(qrData, equals('voicelet://user/123e4567-e89b-12d3-a456-426614174000'));
      });
    });

    group('isOwnQrCode', () {
      test('自分自身のQRコードを正しく検出する', () {
        const userId = '123e4567-e89b-12d3-a456-426614174000';
        const qrData = 'voicelet://user/123e4567-e89b-12d3-a456-426614174000';

        final isOwn = QrCodeUtils.isOwnQrCode(qrData, userId);

        expect(isOwn, isTrue);
      });

      test('他のユーザーのQRコードを正しく検出する', () {
        const currentUserId = '123e4567-e89b-12d3-a456-426614174000';
        const qrData = 'voicelet://user/550e8400-e29b-41d4-a716-446655440000';

        final isOwn = QrCodeUtils.isOwnQrCode(qrData, currentUserId);

        expect(isOwn, isFalse);
      });

      test('無効なQRコードの場合はfalseを返す', () {
        const currentUserId = '123e4567-e89b-12d3-a456-426614174000';
        const invalidQrData = 'https://example.com';

        final isOwn = QrCodeUtils.isOwnQrCode(invalidQrData, currentUserId);

        expect(isOwn, isFalse);
      });
    });
  });
}
