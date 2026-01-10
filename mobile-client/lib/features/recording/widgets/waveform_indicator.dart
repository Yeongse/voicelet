import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 波形インジケーターの設定
class WaveformConfig {
  final Color waveColor;
  final Color progressColor;
  final double height;
  final bool showProgress;
  final int barCount;

  const WaveformConfig({
    this.waveColor = AppTheme.accentPrimary,
    this.progressColor = AppTheme.accentSecondary,
    this.height = 80.0,
    this.showProgress = true,
    this.barCount = 40,
  });
}

/// 録音中の波形インジケーター
/// 音量に応じたリアルタイムなビジュアライゼーション
class RecordingWaveformIndicator extends StatefulWidget {
  final Stream<double> amplitudeStream;
  final WaveformConfig config;

  const RecordingWaveformIndicator({
    super.key,
    required this.amplitudeStream,
    this.config = const WaveformConfig(),
  });

  @override
  State<RecordingWaveformIndicator> createState() =>
      _RecordingWaveformIndicatorState();
}

class _RecordingWaveformIndicatorState extends State<RecordingWaveformIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _amplitudeHistory = [];
  static const int _historyLength = 40;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();

    // 初期化
    for (int i = 0; i < _historyLength; i++) {
      _amplitudeHistory.add(0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: widget.amplitudeStream,
      initialData: 0.0,
      builder: (context, snapshot) {
        final amplitude = snapshot.data ?? 0.0;

        // 履歴を更新
        _amplitudeHistory.removeAt(0);
        _amplitudeHistory.add(amplitude);

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: _LiveWaveformPainter(
                amplitudes: List.from(_amplitudeHistory),
                waveColor: widget.config.waveColor,
                height: widget.config.height,
              ),
              size: Size(double.infinity, widget.config.height),
            );
          },
        );
      },
    );
  }
}

class _LiveWaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color waveColor;
  final double height;

  _LiveWaveformPainter({
    required this.amplitudes,
    required this.waveColor,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = 3.0;
    final barSpacing = (size.width - barWidth * amplitudes.length) /
        (amplitudes.length - 1);
    final maxBarHeight = height - 16;
    final minBarHeight = 4.0;
    final centerY = size.height / 2;

    for (var i = 0; i < amplitudes.length; i++) {
      final amplitude = amplitudes[i];
      final barHeight =
          minBarHeight + (maxBarHeight - minBarHeight) * amplitude;
      final x = i * (barWidth + barSpacing);
      final y = centerY - barHeight / 2;

      // グラデーション効果（中央が明るい）
      final opacity = 0.4 + 0.6 * amplitude;
      final paint = Paint()
        ..color = waveColor.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LiveWaveformPainter oldDelegate) => true;
}

/// 再生用の波形表示（静的波形 + 再生位置）
class PlaybackWaveformIndicator extends StatelessWidget {
  final List<double> waveformData;
  final double progress; // 0.0 - 1.0
  final WaveformConfig config;
  final VoidCallback? onSeek;

  const PlaybackWaveformIndicator({
    super.key,
    required this.waveformData,
    required this.progress,
    this.config = const WaveformConfig(),
    this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onSeek != null ? (details) {} : null,
      child: CustomPaint(
        painter: _WaveformPainter(
          waveformData: waveformData,
          progress: progress,
          waveColor: config.waveColor,
          progressColor: config.progressColor,
          showProgress: config.showProgress,
        ),
        size: Size(double.infinity, config.height),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  final Color waveColor;
  final Color progressColor;
  final bool showProgress;

  _WaveformPainter({
    required this.waveformData,
    required this.progress,
    required this.waveColor,
    required this.progressColor,
    required this.showProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) {
      _drawPlaceholder(canvas, size);
      return;
    }

    final barWidth = 3.0;
    final totalSpacing = size.width - barWidth * waveformData.length;
    final barSpacing = totalSpacing / (waveformData.length - 1);
    final maxBarHeight = size.height - 16;
    final minBarHeight = 4.0;
    final centerY = size.height / 2;

    for (var i = 0; i < waveformData.length; i++) {
      final amplitude = waveformData[i];
      final barHeight =
          minBarHeight + (maxBarHeight - minBarHeight) * amplitude;
      final x = i * (barWidth + barSpacing);
      final y = centerY - barHeight / 2;

      final isPlayed =
          showProgress && (i / waveformData.length) <= progress;
      final color = isPlayed ? progressColor : waveColor;
      final opacity = isPlayed ? 1.0 : 0.5;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  void _drawPlaceholder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final barWidth = 3.0;
    final barCount = 40;
    final totalSpacing = size.width - barWidth * barCount;
    final barSpacing = totalSpacing / (barCount - 1);
    final barHeight = 4.0;
    final centerY = size.height / 2;

    for (var i = 0; i < barCount; i++) {
      final x = i * (barWidth + barSpacing);
      final y = centerY - barHeight / 2;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.waveformData != waveformData;
  }
}

/// 波形データを生成するユーティリティ
class WaveformDataGenerator {
  static final _random = math.Random();

  /// 自然な波形データを生成
  static List<double> generateWaveform({int sampleCount = 50}) {
    final data = <double>[];
    double previous = 0.5;

    for (var i = 0; i < sampleCount; i++) {
      // スムーズな変化を生成
      final target = 0.2 + _random.nextDouble() * 0.6;
      final smoothed = previous * 0.7 + target * 0.3;
      data.add(smoothed.clamp(0.1, 0.9));
      previous = smoothed;
    }
    return data;
  }
}
