import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/theme/app_theme.dart';
import '../models/whisper.dart';
import '../providers/whisper_provider.dart';

/// 開発用: 投稿一覧確認画面
class WhisperListPage extends ConsumerStatefulWidget {
  const WhisperListPage({super.key});

  @override
  ConsumerState<WhisperListPage> createState() => _WhisperListPageState();
}

class _WhisperListPageState extends ConsumerState<WhisperListPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _playingWhisperId;
  String? _loadingWhisperId;
  StreamSubscription<void>? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playingWhisperId = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(Whisper whisper) async {
    if (_playingWhisperId == whisper.id) {
      await _audioPlayer.stop();
      setState(() {
        _playingWhisperId = null;
      });
    } else {
      setState(() {
        _loadingWhisperId = whisper.id;
      });

      try {
        final apiService = ref.read(whisperApiServiceProvider);
        final audioUrlResponse = await apiService.getAudioUrl(whisper.id);

        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(audioUrlResponse.signedUrl));
        setState(() {
          _playingWhisperId = whisper.id;
          _loadingWhisperId = null;
        });
      } catch (e) {
        setState(() {
          _loadingWhisperId = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('再生エラー: $e'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inMinutes < 1) {
        return 'たった今';
      } else if (diff.inHours < 1) {
        return '${diff.inMinutes}分前';
      } else if (diff.inDays < 1) {
        return '${diff.inHours}時間前';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}日前';
      } else {
        return '${dateTime.month}/${dateTime.day}';
      }
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final whispersAsync = ref.watch(whispersProvider);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 背景
          Image.asset(
            'assets/main_background.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
          // コンテンツ
          SafeArea(
            child: Column(
              children: [
                // ヘッダー
                Padding(
                  padding: const EdgeInsets.all(AppTheme.space4),
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
                        onPressed: () => context.go('/'),
                      ),
                      const SizedBox(width: AppTheme.space2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.developer_mode_rounded,
                              color: AppTheme.warning,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '開発用: 投稿一覧',
                              style: TextStyle(
                                fontFamily: 'Quicksand',
                                fontSize: 14,
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
                          ],
                        ),
                      ),
                      const Spacer(),
                      // リフレッシュボタン
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: AppTheme.textPrimary,
                            size: 20,
                          ),
                        ),
                        onPressed: () {
                          ref.invalidate(whispersProvider);
                        },
                      ),
                    ],
                  ),
                ),

                // 一覧
                Expanded(
                  child: whispersAsync.when(
                    data: (whispers) {
                      if (whispers.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.mic_none_rounded,
                                size: 64,
                                color: AppTheme.textTertiary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: AppTheme.space4),
                              const Text(
                                '投稿がありません',
                                style: TextStyle(
                                  color: AppTheme.textTertiary,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: AppTheme.space2),
                              const Text(
                                '録音画面から投稿してみましょう',
                                style: TextStyle(
                                  color: AppTheme.textTertiary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.space4,
                        ),
                        itemCount: whispers.length,
                        itemBuilder: (context, index) {
                          final whisper = whispers[index];
                          return _buildWhisperCard(whisper);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentPrimary,
                      ),
                    ),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 48,
                            color: AppTheme.error,
                          ),
                          const SizedBox(height: AppTheme.space4),
                          Text(
                            'エラーが発生しました',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: AppTheme.space2),
                          Text(
                            error.toString(),
                            style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppTheme.space4),
                          TextButton.icon(
                            onPressed: () {
                              ref.invalidate(whispersProvider);
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('再試行'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhisperCard(Whisper whisper) {
    final isPlaying = _playingWhisperId == whisper.id;
    final isLoading = _loadingWhisperId == whisper.id;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space3),
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          // 再生ボタン
          GestureDetector(
            onTap: isLoading ? null : () => _togglePlay(whisper),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPlaying
                    ? AppTheme.accentPrimary
                    : AppTheme.accentPrimary.withValues(alpha: 0.2),
                border: Border.all(
                  color: AppTheme.accentPrimary.withValues(alpha: 0.3),
                ),
              ),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accentPrimary,
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      color: isPlaying
                          ? AppTheme.textInverse
                          : AppTheme.accentPrimary,
                      size: 24,
                    ),
            ),
          ),

          const SizedBox(width: AppTheme.space4),

          // 情報
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 時間と日時
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _formatDuration(whisper.duration),
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.accentPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.space2),
                    Text(
                      _formatDateTime(whisper.createdAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppTheme.space2),

                // ファイル名
                Text(
                  whisper.fileName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppTheme.space1),

                // ID
                Text(
                  'ID: ${whisper.id.substring(0, 8)}...',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: AppTheme.textTertiary.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // GCSステータス
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_done_rounded,
                  size: 14,
                  color: AppTheme.success,
                ),
                const SizedBox(width: 4),
                Text(
                  'GCS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
