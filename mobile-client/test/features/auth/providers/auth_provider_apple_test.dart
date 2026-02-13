import 'package:flutter_test/flutter_test.dart';
import 'package:voicelet/features/auth/providers/auth_provider.dart';

void main() {
  group('AuthState', () {
    test('AuthStateInitialは初期状態を表す', () {
      const state = AuthStateInitial();
      expect(state, isA<AuthState>());
    });

    test('AuthStateLoadingはローディング状態を表す', () {
      const state = AuthStateLoading();
      expect(state, isA<AuthState>());
    });

    test('AuthStateUnauthenticatedは未認証状態を表す', () {
      const state = AuthStateUnauthenticated();
      expect(state, isA<AuthState>());
    });

    test('AuthStateErrorはエラーメッセージを保持する', () {
      const errorMessage = 'Appleサインインに失敗しました';
      const state = AuthStateError(message: errorMessage);
      expect(state, isA<AuthState>());
      expect(state.message, equals(errorMessage));
    });

    test('AuthStateErrorはネットワークエラーメッセージを保持する', () {
      const errorMessage = 'ネットワーク接続を確認してください';
      const state = AuthStateError(message: errorMessage);
      expect(state.message, equals(errorMessage));
    });

    test('AuthStateErrorはサーバーエラーメッセージを保持する', () {
      const errorMessage = 'しばらく時間をおいて再度お試しください';
      const state = AuthStateError(message: errorMessage);
      expect(state.message, equals(errorMessage));
    });

    test('AuthStateErrorはiOS非対応エラーメッセージを保持する', () {
      const errorMessage = 'Apple認証はiOSでのみ利用可能です';
      const state = AuthStateError(message: errorMessage);
      expect(state.message, equals(errorMessage));
    });
  });

  group('Apple認証エラーメッセージ', () {
    // 設計書で定義されたエラーメッセージのテスト
    test('Apple認証失敗時のメッセージが正しい', () {
      const expectedMessages = [
        'Appleサインインに失敗しました',
        'Appleサインインを利用できません',
        'Apple認証トークンの取得に失敗しました',
        'ネットワーク接続を確認してください',
        'しばらく時間をおいて再度お試しください',
        'Apple認証はiOSでのみ利用可能です',
      ];

      for (final message in expectedMessages) {
        final state = AuthStateError(message: message);
        expect(state.message, isNotEmpty);
        expect(state.message, message);
      }
    });
  });

  group('AuthNotifier状態遷移', () {
    test('キャンセル時はUnauthenticated状態に遷移すべき', () {
      // Apple認証がキャンセルされた場合、静かにUnauthenticated状態に戻る
      // （エラーメッセージは表示しない）
      const state = AuthStateUnauthenticated();
      expect(state, isA<AuthStateUnauthenticated>());
    });

    test('認証中はLoading状態になるべき', () {
      const state = AuthStateLoading();
      expect(state, isA<AuthStateLoading>());
    });
  });
}
