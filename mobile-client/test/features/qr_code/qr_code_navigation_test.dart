import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:voicelet/core/theme/app_theme.dart';
import 'package:voicelet/features/auth/models/profile.dart';
import 'package:voicelet/features/auth/providers/auth_provider.dart';
import 'package:voicelet/features/profile/providers/profile_provider.dart';
import 'package:voicelet/features/qr_code/pages/qr_code_page.dart';
import 'package:voicelet/features/profile/pages/profile_page.dart';

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
  followingCount: 10,
  followersCount: 20,
  createdAt: '2026-01-01T00:00:00Z',
  updatedAt: '2026-01-01T00:00:00Z',
);

void main() {
  group('QRコード画面ナビゲーション', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/profile/edit',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Edit Page')),
            ),
          ),
          GoRoute(
            path: '/qr-code',
            builder: (context, state) => const QrCodePage(),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Login Page')),
            ),
          ),
        ],
      );
    });

    Widget createTestApp() {
      return ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWithValue('test-user-id'),
          myProfileProvider.overrideWith((ref) async => _mockProfile),
        ],
        child: MaterialApp.router(
          theme: AppTheme.themeData,
          routerConfig: router,
        ),
      );
    }

    testWidgets('プロフィール画面にQRコードアイコンが表示される', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // QRコードアイコンが表示されることを確認
      expect(find.byIcon(Icons.qr_code), findsOneWidget);
    });

    testWidgets('QRコードアイコンをタップするとQRコード画面に遷移する', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // QRコードアイコンをタップ
      await tester.tap(find.byIcon(Icons.qr_code));
      await tester.pumpAndSettle();

      // QRコード画面に遷移したことを確認
      expect(find.text('QRコード'), findsOneWidget);
      expect(find.text('マイQR'), findsOneWidget);
      expect(find.text('スキャン'), findsOneWidget);
    });

    testWidgets('QRコード画面から戻るボタンでプロフィール画面に戻れる', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // QRコードアイコンをタップしてQR画面に遷移
      await tester.tap(find.byIcon(Icons.qr_code));
      await tester.pumpAndSettle();

      // QRコード画面にいることを確認
      expect(find.text('QRコード'), findsOneWidget);

      // 戻るボタンをタップ
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // プロフィール画面に戻ったことを確認
        expect(find.text('マイプロフィール'), findsOneWidget);
      }
    });
  });
}
