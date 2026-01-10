import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/waveform_indicator.dart';

/// プレビュー画面
class PreviewPage extends StatefulWidget {
  final String filePath;
  final String fileName;
  final Duration duration;

  const PreviewPage({
    super.key,
    required this.filePath,
    required this.fileName,
    required this.duration,
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final StorageService _storageService = StorageService();

  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _totalDuration = Duration.zero;
  List<double> _waveformData = [];

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _generateWaveformData();
    _setupAnimations();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  Future<void> _initPlayer() async {
    await _audioPlayer.setSourceDeviceFile(widget.filePath);

    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _playerState = state;
      });
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });
  }

  void _generateWaveformData() {
    setState(() {
      _waveformData = WaveformDataGenerator.generateWaveform(sampleCount: 50);
    });
  }

  Future<void> _togglePlayback() async {
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> _reRecord() async {
    try {
      await _storageService.deleteFile(widget.filePath);
    } catch (_) {}

    if (mounted) {
      context.pop();
    }
  }

  void _showReRecordConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgElevated.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        ),
        title: const Text(
          '再録音しますか？',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          '現在の録音は破棄されます。',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'キャンセル',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _reRecord();
            },
            child: const Text(
              '再録音する',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
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
    final isPlaying = _playerState == PlayerState.playing;
    final effectiveDuration =
        _totalDuration.inMilliseconds > 0 ? _totalDuration : widget.duration;
    final progress = effectiveDuration.inMilliseconds > 0
        ? _position.inMilliseconds / effectiveDuration.inMilliseconds
        : 0.0;

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
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.15),
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
                              Icons.arrow_back_rounded,
                              color: AppTheme.textPrimary,
                              size: 20,
                            ),
                          ),
                          onPressed: () => context.pop(),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'プレビュー',
                            style: TextStyle(
                              fontFamily: 'Quicksand',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48), // バランス用
                      ],
                    ),
                  ),

                  const Spacer(flex: 1),

                  // 録音完了メッセージ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space5,
                      vertical: AppTheme.space3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                        color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.accentPrimary,
                          size: 18,
                          shadows: [
                            Shadow(
                              color: AppTheme.accentPrimary.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        const SizedBox(width: AppTheme.space2),
                        Text(
                          '録音が完了しました',
                          style: TextStyle(
                            color: AppTheme.accentPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.space8),

                  // 録音時間
                  Text(
                    _formatDuration(effectiveDuration),
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 56,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.textPrimary,
                      letterSpacing: 6,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 15,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 波形表示
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
                    child: PlaybackWaveformIndicator(
                      waveformData: _waveformData,
                      progress: progress,
                      config: const WaveformConfig(
                        waveColor: AppTheme.textTertiary,
                        progressColor: AppTheme.accentPrimary,
                        height: 80,
                        showProgress: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.space3),

                  // 再生位置表示
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space6 + AppTheme.space4,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDuration(_position),
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _formatDuration(effectiveDuration),
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 再生ボタン
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (context, child) {
                      final glowIntensity = 0.25 + (_glowController.value * 0.15);
                      return GestureDetector(
                        onTap: _togglePlayback,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.gradientAccent,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentPrimary
                                    .withValues(alpha: glowIntensity),
                                blurRadius: 35,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: AppTheme.textInverse,
                            size: 44,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppTheme.space8),

                  // アクションボタン
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space6,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.refresh_rounded,
                            label: '再録音',
                            onTap: _showReRecordConfirmation,
                            isDestructive: true,
                          ),
                        ),
                        const SizedBox(width: AppTheme.space4),
                        Expanded(
                          child: _buildActionButton(
                            icon: Icons.send_rounded,
                            label: '投稿する',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: AppTheme.accentPrimary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        '投稿しました',
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor:
                                      AppTheme.bgElevated.withValues(alpha: 0.95),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppTheme.radiusMd,
                                    ),
                                  ),
                                ),
                              );
                            },
                            isPrimary: true,
                          ),
                        ),
                      ],
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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isPrimary = false,
  }) {
    final Color bgColor;
    final Color textColor;
    final Color iconColor;
    final List<BoxShadow>? boxShadow;

    if (isPrimary) {
      bgColor = AppTheme.accentPrimary;
      textColor = AppTheme.textInverse;
      iconColor = AppTheme.textInverse;
      boxShadow = [
        BoxShadow(
          color: AppTheme.accentPrimary.withValues(alpha: 0.4),
          blurRadius: 15,
          spreadRadius: 1,
        ),
      ];
    } else if (isDestructive) {
      bgColor = Colors.black.withValues(alpha: 0.4);
      textColor = AppTheme.textPrimary;
      iconColor = AppTheme.textPrimary.withValues(alpha: 0.9);
      boxShadow = [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else {
      bgColor = Colors.black.withValues(alpha: 0.3);
      textColor = AppTheme.textPrimary;
      iconColor = AppTheme.textSecondary;
      boxShadow = null;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.space4,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: boxShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppTheme.space2),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
