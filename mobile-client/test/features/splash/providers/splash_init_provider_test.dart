import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:voicelet/features/splash/models/splash_result.dart';
import 'package:voicelet/features/splash/providers/splash_init_provider.dart';

void main() {
  group('splashInitProvider', () {
    test('正常系: 最低1.5秒後にSplashSuccessを返す', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final stopwatch = Stopwatch()..start();
      final result = await container.read(splashInitProvider.future);
      stopwatch.stop();

      expect(result, isA<SplashSuccess>());
      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(1500));
    });

    test('splashMinDisplayDurationは1.5秒', () {
      expect(splashMinDisplayDuration, equals(const Duration(milliseconds: 1500)));
    });

    test('splashTimeoutDurationは10秒', () {
      expect(splashTimeoutDuration, equals(const Duration(seconds: 10)));
    });
  });
}
