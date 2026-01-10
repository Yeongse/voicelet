import 'package:flutter_test/flutter_test.dart';
import 'package:voicelet/features/splash/models/splash_result.dart';

void main() {
  group('SplashResult', () {
    test('SplashSuccess を生成できる', () {
      const result = SplashSuccess();
      expect(result, isA<SplashResult>());
      expect(result, isA<SplashSuccess>());
    });

    test('SplashTimeout を生成できる', () {
      const result = SplashTimeout();
      expect(result, isA<SplashResult>());
      expect(result, isA<SplashTimeout>());
    });

    test('SplashNetworkError を生成できる', () {
      const result = SplashNetworkError('Connection failed');
      expect(result, isA<SplashResult>());
      expect(result, isA<SplashNetworkError>());
      expect(result.message, equals('Connection failed'));
    });

    test('switch 式でパターンマッチングできる', () {
      const SplashResult success = SplashSuccess();
      const SplashResult timeout = SplashTimeout();
      const SplashResult error = SplashNetworkError('Error');

      expect(
        switch (success) {
          SplashSuccess() => 'success',
          SplashTimeout() => 'timeout',
          SplashNetworkError() => 'error',
        },
        equals('success'),
      );

      expect(
        switch (timeout) {
          SplashSuccess() => 'success',
          SplashTimeout() => 'timeout',
          SplashNetworkError() => 'error',
        },
        equals('timeout'),
      );

      expect(
        switch (error) {
          SplashSuccess() => 'success',
          SplashTimeout() => 'timeout',
          SplashNetworkError(message: final msg) => msg,
        },
        equals('Error'),
      );
    });
  });
}
