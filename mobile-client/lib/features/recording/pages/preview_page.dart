import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/waveform_indicator.dart';
import '../widgets/particle_background.dart';

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
    with SingleTickerProviderStateMixin {
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
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
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
        backgroundColor: AppTheme.bgElevated,
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

    return ParticleBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppTheme.textSecondary,
            ),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Preview',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space6),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // 録音完了メッセージ
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space5,
                      vertical: AppTheme.space3,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.accentPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.accentPrimary,
                          size: 18,
                        ),
                        SizedBox(width: AppTheme.space2),
                        Text(
                          '録音が完了しました',
                          style: TextStyle(
                            color: AppTheme.accentPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.space10),

                  // 録音時間
                  Text(
                    _formatDuration(effectiveDuration),
                    style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: AppTheme.textPrimary,
                      letterSpacing: 4,
                    ),
                  ),

                  const Spacer(),

                  // 波形表示
                  Container(
                    height: 100,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space4,
                    ),
                    child: PlaybackWaveformIndicator(
                      waveformData: _waveformData,
                      progress: progress,
                      config: const WaveformConfig(
                        waveColor: AppTheme.textTertiary,
                        progressColor: AppTheme.accentPrimary,
                        height: 100,
                        showProgress: true,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.space4),

                  // 再生位置表示
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppTheme.space4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                        Text(
                          _formatDuration(effectiveDuration),
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 12,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 再生ボタン
                  GestureDetector(
                    onTap: _togglePlayback,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.gradientAccent,
                        boxShadow: AppTheme.glowAccent,
                      ),
                      child: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: AppTheme.textInverse,
                        size: 40,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppTheme.space10),

                  // アクションボタン
                  Row(
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
                          icon: Icons.check_rounded,
                          label: '保存する',
                          onTap: () {
                            // Phase 2: クラウドアップロード
                            // 今はローカル保存のみ
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('録音を保存しました'),
                                backgroundColor: AppTheme.bgElevated,
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

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
        ),
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

    if (isPrimary) {
      bgColor = AppTheme.accentPrimary;
      textColor = AppTheme.textInverse;
      iconColor = AppTheme.textInverse;
    } else if (isDestructive) {
      bgColor = AppTheme.error.withValues(alpha: 0.15);
      textColor = AppTheme.error;
      iconColor = AppTheme.error;
    } else {
      bgColor = AppTheme.bgTertiary;
      textColor = AppTheme.textPrimary;
      iconColor = AppTheme.textSecondary;
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
          border: isDestructive
              ? Border.all(color: AppTheme.error.withValues(alpha: 0.3))
              : null,
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
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
