import 'package:flutter_test/flutter_test.dart';
import 'package:voicelet/features/splash/models/splash_result.dart';

void main() {
  group('SplashResult', () {
    test('SplashSuccess を生成できる', () {
      const result = SplashSuccess();
      expect(result, isA<SplashResult>());
      expect(result, isA<SplashSuccess>());
    });

    test('SplashNeedsOnboarding を生成できる', () {
      const result = SplashNeedsOnboarding();
      expect(result, isA<SplashResult>());
      expect(result, isA<SplashNeedsOnboarding>());
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

    test('SplashUnauthenticated を生成できる', () {
      const result = SplashUnauthenticated();
      expect(result, isA<SplashResult>());
      expect(result, isA<SplashUnauthenticated>());
    });

    test('switch 式でパターンマッチングできる', () {
      const SplashResult success = SplashSuccess();
      const SplashResult needsOnboarding = SplashNeedsOnboarding();
      const SplashResult timeout = SplashTimeout();
      const SplashResult error = SplashNetworkError('Error');
      const SplashResult unauthenticated = SplashUnauthenticated();

      expect(
        switch (success) {
          SplashSuccess() => 'success',
          SplashNeedsOnboarding() => 'needsOnboarding',
          SplashUnauthenticated() => 'unauthenticated',
          SplashTimeout() => 'timeout',
          SplashNetworkError() => 'error',
        },
        equals('success'),
      );

      expect(
        switch (needsOnboarding) {
          SplashSuccess() => 'success',
          SplashNeedsOnboarding() => 'needsOnboarding',
          SplashUnauthenticated() => 'unauthenticated',
          SplashTimeout() => 'timeout',
          SplashNetworkError() => 'error',
        },
        equals('needsOnboarding'),
      );

      expect(
        switch (timeout) {
          SplashSuccess() => 'success',
          SplashNeedsOnboarding() => 'needsOnboarding',
          SplashUnauthenticated() => 'unauthenticated',
          SplashTimeout() => 'timeout',
          SplashNetworkError() => 'error',
        },
        equals('timeout'),
      );

      expect(
        switch (error) {
          SplashSuccess() => 'success',
          SplashNeedsOnboarding() => 'needsOnboarding',
          SplashUnauthenticated() => 'unauthenticated',
          SplashTimeout() => 'timeout',
          SplashNetworkError(message: final msg) => msg,
        },
        equals('Error'),
      );

      expect(
        switch (unauthenticated) {
          SplashSuccess() => 'success',
          SplashNeedsOnboarding() => 'needsOnboarding',
          SplashUnauthenticated() => 'unauthenticated',
          SplashTimeout() => 'timeout',
          SplashNetworkError() => 'error',
        },
        equals('unauthenticated'),
      );
    });
  });
}
