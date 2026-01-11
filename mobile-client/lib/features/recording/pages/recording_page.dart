import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../services/recording_service.dart';
import '../widgets/waveform_indicator.dart';

/// 録音画面
class RecordingPage extends ConsumerStatefulWidget {
  const RecordingPage({super.key});

  @override
  ConsumerState<RecordingPage> createState() => _RecordingPageState();
}

class _RecordingPageState extends ConsumerState<RecordingPage>
    with TickerProviderStateMixin {
  late RecordingService _recordingService;
  RecordingState _recordingState = RecordingState.idle;
  Duration _elapsed = Duration.zero;
  StreamSubscription<RecordingState>? _stateSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  String? _errorMessage;

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _recordingService = RecordingService();
    _setupListeners();
    _setupAnimations();
  }

  void _setupAnimations() {
    // 録音中のパルスアニメーション
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // フェードインアニメーション
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // グロー用コントローラー
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  void _setupListeners() {
    _stateSubscription = _recordingService.stateStream.listen((state) {
      setState(() {
        _recordingState = state;
      });

      if (state == RecordingState.recording) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }

      if (state == RecordingState.stopped) {
        _navigateToPreview();
      }
    });

    _durationSubscription = _recordingService.durationStream.listen((duration) {
      setState(() {
        _elapsed = duration;
      });
    });
  }

  Future<void> _startRecording() async {
    setState(() {
      _errorMessage = null;
    });

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      setState(() {
        _errorMessage = 'ユーザー情報が取得できません';
      });
      return;
    }

    try {
      await _recordingService.startRecording(userId);
    } on PermissionDeniedException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      _showPermissionDialog();
    } catch (e) {
      setState(() {
        _errorMessage = '録音の開始に失敗しました';
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      final result = await _recordingService.stopRecording();
      _navigateToPreviewWithResult(result);
    } catch (e) {
      setState(() {
        _errorMessage = '録音の停止に失敗しました';
      });
    }
  }

  void _navigateToPreview() async {}

  void _navigateToPreviewWithResult(RecordingResult result) {
    context.push(
      '/recording/preview',
      extra: {
        'filePath': result.filePath,
        'fileName': result.fileName,
        'duration': result.duration,
      },
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgElevated.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        title: const Text(
          'マイクへのアクセス',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'マイクへのアクセスが許可されていません。\n設定からアクセスを許可してください。',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('閉じる'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('設定を開く'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _durationSubscription?.cancel();
    _recordingService.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final seconds = duration.inSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isRecording = _recordingState == RecordingState.recording;
    final remainingSeconds = 30 - _elapsed.inSeconds;
    final progress = _elapsed.inSeconds / 30.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景画像
          Image.asset(
            'assets/main_background.png',
            fit: BoxFit.cover,
          ),
          // グラデーションオーバーレイ
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.4),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
          // コンテンツ
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // AppBar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space2,
                      vertical: AppTheme.space2,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: AppTheme.textPrimary,
                              size: 20,
                            ),
                          ),
                          onPressed: () async {
                            if (isRecording) {
                              await _recordingService.cancelRecording();
                            }
                            if (context.mounted) {
                              context.go('/');
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // エラーメッセージ
                  if (_errorMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space6,
                      ),
                      child: _buildErrorBanner(),
                    ),
                    const SizedBox(height: AppTheme.space6),
                  ],

                  // タイトル
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isRecording ? '録音中...' : '声を残そう',
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.space8),

                  // 経過時間表示
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      final glowIntensity = isRecording
                          ? 0.3 + (_glowController.value * 0.2)
                          : 0.0;
                      return Text(
                        _formatDuration(_elapsed),
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 64,
                          fontWeight: FontWeight.w300,
                          color: AppTheme.textPrimary,
                          letterSpacing: 6,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              blurRadius: 15,
                              offset: const Offset(0, 2),
                            ),
                            if (isRecording)
                              Shadow(
                                color: AppTheme.error.withValues(alpha: glowIntensity),
                                blurRadius: 30,
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.space2),

                  // 残り時間 / 最大時間
                  AnimatedSwitcher(
                    duration: AppTheme.durationNormal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: isRecording
                          ? Text(
                              '残り $remainingSeconds秒',
                              key: const ValueKey('remaining'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: remainingSeconds <= 5
                                    ? AppTheme.error
                                    : AppTheme.textSecondary,
                              ),
                            )
                          : const Text(
                              '最大30秒',
                              key: ValueKey('max'),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                    ),
                  ),

                  const Spacer(),

                  // 波形インジケーター
                  Container(
                    height: 100,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space4,
                      vertical: AppTheme.space3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: isRecording
                        ? RecordingWaveformIndicator(
                            amplitudeStream: _recordingService.amplitudeStream,
                            config: const WaveformConfig(
                              waveColor: AppTheme.accentPrimary,
                              height: 80,
                            ),
                          )
                        : _buildIdleWaveform(),
                  ),

                  // プログレスバー（録音中のみ）
                  if (isRecording) ...[
                    const SizedBox(height: AppTheme.space4),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.space6,
                      ),
                      child: _buildProgressBar(progress),
                    ),
                  ],

                  const Spacer(),

                  // 録音ボタン
                  _buildRecordButton(isRecording),

                  const SizedBox(height: AppTheme.space4),

                  // ボタンラベル
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isRecording ? 'タップで停止' : 'タップで録音開始',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary.withValues(alpha: 0.8),
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: AppTheme.error.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.error.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.error,
            size: 20,
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                color: AppTheme.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleWaveform() {
    return CustomPaint(
      painter: _IdleWaveformPainter(),
      size: const Size(double.infinity, 80),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.gradientAccent,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentPrimary.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecordButton(bool isRecording) {
    return GestureDetector(
      onTap: isRecording ? _stopRecording : _startRecording,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseAnimation, _glowController]),
        builder: (context, child) {
          final glowIntensity = 0.3 + (_glowController.value * 0.2);
          return Transform.scale(
            scale: isRecording ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isRecording
                    ? AppTheme.gradientRecording
                    : AppTheme.gradientAccent,
                boxShadow: [
                  BoxShadow(
                    color: (isRecording
                            ? AppTheme.error
                            : AppTheme.accentPrimary)
                        .withValues(alpha: glowIntensity),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: AppTheme.durationFast,
                  child: isRecording
                      ? Container(
                          key: const ValueKey('stop'),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.textPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      : const Icon(
                          key: ValueKey('mic'),
                          Icons.mic_rounded,
                          color: AppTheme.textInverse,
                          size: 48,
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _IdleWaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentPrimary.withValues(alpha: 0.25)
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
