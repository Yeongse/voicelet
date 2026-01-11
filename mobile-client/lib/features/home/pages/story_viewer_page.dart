import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_theme.dart';
import '../models/home_models.dart';
import '../providers/home_providers.dart';
import '../../auth/providers/auth_provider.dart';

/// ストーリービューワー（Instagram風）
class StoryViewerPage extends ConsumerStatefulWidget {
  final UserStory story;

  const StoryViewerPage({
    super.key,
    required this.story,
  });

  @override
  ConsumerState<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends ConsumerState<StoryViewerPage>
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = true;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _durationSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // パルスアニメーション（拡大縮小）
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 波形アニメーション
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _setupAudioListeners();
    _loadCurrentStory();
  }

  void _setupAudioListeners() {
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });

      // アニメーション制御
      if (state == PlayerState.playing) {
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
      } else {
        _pulseController.stop();
        _waveController.stop();
      }

      // 再生完了時に次へ
      if (state == PlayerState.completed) {
        _goToNext();
      }
    });
  }

  Future<void> _loadCurrentStory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final story = widget.story.stories[_currentIndex];
      final apiService = ref.read(homeApiServiceProvider);
      final audioUrl = await apiService.getAudioUrl(whisperId: story.id);

      await _audioPlayer.setSourceUrl(audioUrl);
      await _audioPlayer.resume();

      // 視聴記録を送信
      final userId = ref.read(currentUserIdProvider);
      if (userId != null && !story.isViewed) {
        await apiService.recordView(userId: userId, whisperId: story.id);
      }
    } catch (e) {
      debugPrint('Error loading audio: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _audioPlayer.stop();
      setState(() {
        _currentIndex--;
        _currentPosition = Duration.zero;
      });
      _loadCurrentStory();
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.story.stories.length - 1) {
      _audioPlayer.stop();
      setState(() {
        _currentIndex++;
        _currentPosition = Duration.zero;
      });
      _loadCurrentStory();
    } else {
      // 最後のストーリー終了
      context.pop();
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: GestureDetector(
        onTapUp: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < screenWidth / 3) {
            _goToPrevious();
          } else if (details.localPosition.dx > screenWidth * 2 / 3) {
            _goToNext();
          } else {
            _togglePlayPause();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 背景
            Image.asset(
              'assets/main_background.png',
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withValues(alpha: 0.6),
            ),

            // コンテンツ
            SafeArea(
              child: Column(
                children: [
                  // プログレスバー
                  _buildProgressBars(),

                  // ヘッダー
                  _buildHeader(),

                  // メインコンテンツ
                  Expanded(
                    child: Center(
                      child: _isLoading
                          ? _buildLoadingIndicator()
                          : _buildAudioVisualizer(),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBars() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: List.generate(widget.story.stories.length, (index) {
          double progress = 0;
          if (index < _currentIndex) {
            progress = 1;
          } else if (index == _currentIndex) {
            final total = _totalDuration.inMilliseconds;
            final current = _currentPosition.inMilliseconds;
            progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0;
          }

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.textPrimary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.textPrimary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // ユーザーアバター
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.textPrimary, width: 2),
            ),
            child: ClipOval(
              child: widget.story.user.avatarUrl != null
                  ? Image.network(
                      widget.story.user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(width: 12),

          // ユーザー名
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.story.user.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _formatTime(widget.story.stories[_currentIndex].createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 閉じるボタン
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppTheme.bgTertiary,
      child: Center(
        child: Text(
          widget.story.user.name.isNotEmpty
              ? widget.story.user.name[0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(
            color: AppTheme.accentPrimary,
            strokeWidth: 3,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '読み込み中...',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildAudioVisualizer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // アニメーション付きオーディオビジュアライザー
        AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _waveController]),
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // 外側のリング（パルス）
                if (_isPlaying)
                  Transform.scale(
                    scale: 1.0 + (_pulseAnimation.value - 1.0) * 2,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.accentPrimary.withValues(
                            alpha: 0.3 * (1.0 - (_pulseAnimation.value - 1.0) * 5),
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                // メインの円
                Transform.scale(
                  scale: _isPlaying ? _pulseAnimation.value : 1.0,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.bgElevated.withValues(alpha: 0.9),
                      boxShadow: _isPlaying ? AppTheme.glowAccent : [],
                    ),
                    child: Center(
                      child: _isPlaying
                          ? _buildSoundBars()
                          : Icon(
                              Icons.play_arrow_rounded,
                              size: 64,
                              color: AppTheme.accentPrimary,
                            ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 32),

        // 再生時間表示
        Text(
          '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildSoundBars() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            // 各バーに異なる位相のアニメーション
            final phase = index * 0.2;
            final animValue = ((_waveController.value + phase) % 1.0);
            final height = 20 + 24 * math.sin(animValue * math.pi);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: height,
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTime(String isoString) {
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分前';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}時間前';
    } else {
      return '${diff.inDays}日前';
    }
  }
}
