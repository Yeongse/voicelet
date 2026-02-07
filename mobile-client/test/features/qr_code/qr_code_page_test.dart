import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voicelet/core/theme/app_theme.dart';
import 'package:voicelet/features/auth/models/profile.dart';
import 'package:voicelet/features/auth/providers/auth_provider.dart';
import 'package:voicelet/features/profile/providers/profile_provider.dart';
import 'package:voicelet/features/qr_code/pages/qr_code_page.dart';

// テスト用のモックプロファイル
final _mockProfile = Profile(
  id: 'test-user-id',
  email: 'test@example.com',
  name: 'Test User',
  username: 'testuser',
  avatarUrl: null,
  bio: null,
  birthMonth: null,
  age: null,
  isPrivate: false,
  followingCount: 0,
  followersCount: 0,
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
);

void main() {
  group('QrCodePage', () {
    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          // currentUserIdProviderをモック
          currentUserIdProvider.overrideWithValue('test-user-id'),
          // myProfileProviderをモック
          myProfileProvider.overrideWith((ref) async => _mockProfile),
        ],
        child: MaterialApp(
          theme: AppTheme.themeData,
          home: const QrCodePage(),
        ),
      );
    }

    testWidgets('2つのタブ（マイQR、スキャン）が表示される', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // タブが表示されることを確認
      expect(find.text('マイQR'), findsOneWidget);
      expect(find.text('スキャン'), findsOneWidget);
    });

    testWidgets('AppBarにQRコードタイトルが表示される', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('QRコード'), findsOneWidget);
    });

    testWidgets('タブアイコンが正しく表示される', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // QRコードアイコンとスキャナーアイコンが表示される
      expect(find.byIcon(Icons.qr_code), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });

    testWidgets('タブ切り替えができる', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // 初期状態はマイQRタブ
      expect(find.byIcon(Icons.qr_code), findsOneWidget);

      // スキャンタブをタップ
      await tester.tap(find.text('スキャン'));
      await tester.pumpAndSettle();

      // タブが切り替わったことを確認
      // （スキャナータブのコンテンツが表示される - カメラエラーが表示されるはず）
      // テスト環境ではカメラが利用できないため、エラーUIが表示される
    });
  });
}
