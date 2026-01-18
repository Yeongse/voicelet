import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dialogs.dart';
import '../models/home_models.dart';
import '../providers/home_providers.dart';

/// 自分のストーリー閲覧ページ
/// シーク再生、閲覧者一覧、削除機能を提供
class MyStoryViewerPage extends ConsumerStatefulWidget {
  final MyWhisper whisper;

  const MyStoryViewerPage({
    super.key,
    required this.whisper,
  });

  @override
  ConsumerState<MyStoryViewerPage> createState() => _MyStoryViewerPageState();
}

class _MyStoryViewerPageState extends ConsumerState<MyStoryViewerPage>
    with TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;

  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isCompleted = false; // 再生完了状態を追跡
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _audioUrl; // 再生用にURLを保持

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<void>? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _setupAudioListeners();
    _loadStory();
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

    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });

      if (state == PlayerState.playing) {
        _pulseController.repeat(reverse: true);
        _waveController.repeat();
      } else {
        _pulseController.stop();
        _waveController.stop();
      }

      // 再生完了時は停止状態で待機
    });

    // 再生完了時にpositionを0にリセット
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _currentPosition = Duration.zero;
          _isCompleted = true; // 再生完了状態をマーク
        });
      }
    });
  }

  Future<void> _loadStory() async {
    setState(() {
      _isLoading = true;
      _currentPosition = Duration.zero;
      _totalDuration = Duration.zero;
    });

    try {
      final apiService = ref.read(homeApiServiceProvider);
      _audioUrl = await apiService.getAudioUrl(whisperId: widget.whisper.id);
      await _audioPlayer.setSourceUrl(_audioUrl!);
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Error loading audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
                const SizedBox(width: 12),
                Text(
                  '音声の読み込みに失敗しました',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
            backgroundColor: AppTheme.bgElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      // 再生完了状態の場合は、stop() して play() で最初から再生
      if (_isCompleted && _audioUrl != null) {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(_audioUrl!));
        setState(() {
          _isCompleted = false;
        });
      } else {
        await _audioPlayer.resume();
      }
    }
  }

  void _seekTo(double value) {
    final position = Duration(milliseconds: (value * _totalDuration.inMilliseconds).round());
    _audioPlayer.seek(position);
    // シーク操作で再生完了状態をリセット
    if (_isCompleted) {
      setState(() {
        _isCompleted = false;
      });
    }
  }

  void _closeViewer() {
    context.pop();
  }

  Future<void> _showViewersBottomSheet() async {
    // 再生を一時停止
    if (_isPlaying) {
      _audioPlayer.pause();
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ViewersBottomSheet(whisperId: widget.whisper.id),
    );
  }

  Future<void> _showDeleteConfirmDialog() async {
    final confirmed = await showDestructiveConfirmDialog(
      context: context,
      message: 'このストーリーを削除しますか？\nこの操作は取り消せません。',
      destructiveText: 'ストーリーを削除',
    );

    if (confirmed) {
      await _deleteStory();
    }
  }

  Future<void> _deleteStory() async {
    final success = await ref.read(deleteWhisperProvider.notifier).deleteWhisper(widget.whisper.id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded, color: AppTheme.success, size: 20),
                const SizedBox(width: 12),
                Text(
                  'ストーリーを削除しました',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
            backgroundColor: AppTheme.bgElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        // 画面を閉じてホームへ戻る
        _closeViewer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: AppTheme.error, size: 20),
                const SizedBox(width: 12),
                Text(
                  '削除に失敗しました',
                  style: TextStyle(color: AppTheme.textPrimary),
                ),
              ],
            ),
            backgroundColor: AppTheme.bgElevated,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
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
        onTap: _togglePlayPause,
        onVerticalDragEnd: (details) {
          // 上スワイプで閲覧者一覧表示
          if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
            _showViewersBottomSheet();
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
                  // プログレスバー（単一ストーリー）
                  _buildProgressBar(),

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

                  // 閲覧者確認ボタン
                  _buildViewerButton(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _totalDuration.inMilliseconds > 0
        ? (_currentPosition.inMilliseconds / _totalDuration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: AppTheme.textPrimary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.textPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // My Storyアイコン
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.gradientAccent,
            ),
            child: const Center(
              child: Icon(
                Icons.mic_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // タイトルと時間
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Story',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  _formatTime(widget.whisper.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 削除ボタン
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.textPrimary,
            ),
            onPressed: _showDeleteConfirmDialog,
          ),

          // 閉じるボタン
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: AppTheme.textPrimary,
            ),
            onPressed: _closeViewer,
          ),
        ],
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

        const SizedBox(height: 24),

        // 再生時間表示
        Text(
          '${_formatDuration(_currentPosition)} / ${_formatDuration(_totalDuration)}',
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textSecondary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),

        // シークバー（秒数表示のすぐ下に配置）
        if (!_isLoading) _buildSeekBar(),
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

  Widget _buildSeekBar() {
    final progress = _totalDuration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.accentPrimary,
              inactiveTrackColor: AppTheme.textSecondary.withValues(alpha: 0.3),
              thumbColor: AppTheme.accentPrimary,
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: _seekTo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewerButton() {
    return Consumer(
      builder: (context, ref, child) {
        final viewersAsync = ref.watch(viewersProvider(widget.whisper.id));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _showViewersBottomSheet,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.bgElevated.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                    color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      color: AppTheme.textPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    viewersAsync.when(
                      data: (response) => Text(
                        '${response.totalCount}人が閲覧',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      loading: () => Text(
                        '読み込み中...',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      error: (_, _) => Text(
                        '閲覧者を取得できませんでした',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
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

/// 閲覧者一覧ボトムシート
class _ViewersBottomSheet extends ConsumerWidget {
  final String whisperId;

  const _ViewersBottomSheet({required this.whisperId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewersAsync = ref.watch(viewersProvider(whisperId));

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.bgElevated,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              // ヘッダー
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.visibility_outlined, color: AppTheme.textPrimary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: viewersAsync.when(
                        data: (response) => Text(
                          '閲覧者 ${response.totalCount}人',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        loading: () => Text(
                          '閲覧者',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        error: (_, _) => Text(
                          '閲覧者',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    // 閉じるボタン
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppTheme.textPrimary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Divider(color: AppTheme.textSecondary.withValues(alpha: 0.2)),
              // リスト
              Expanded(
                child: viewersAsync.when(
                  data: (response) {
                    if (response.data.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: response.data.length,
                      itemBuilder: (context, index) {
                        final viewer = response.data[index];
                        return _ViewerTile(
                          viewer: viewer,
                          onTap: () {
                            Navigator.pop(context);
                            context.push('/users/${viewer.id}');
                          },
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text(
                      'エラーが発生しました',
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.visibility_off_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'まだ閲覧者がいません',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 閲覧者タイル
class _ViewerTile extends StatelessWidget {
  final WhisperViewer viewer;
  final VoidCallback onTap;

  const _ViewerTile({
    required this.viewer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 22,
        backgroundColor: AppTheme.bgTertiary,
        backgroundImage: viewer.avatarUrl != null
            ? NetworkImage(viewer.avatarUrl!)
            : null,
        child: viewer.avatarUrl == null
            ? Text(
                viewer.name.isNotEmpty ? viewer.name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              )
            : null,
      ),
      title: Text(
        viewer.name,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _formatViewedAt(viewer.viewedAt),
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppTheme.textSecondary,
      ),
    );
  }

  String _formatViewedAt(String isoString) {
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}分前に閲覧';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}時間前に閲覧';
    } else {
      return '${diff.inDays}日前に閲覧';
    }
  }
}
