import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/home_models.dart';
import '../providers/home_providers.dart';
import 'add_story_button.dart';

/// My Storyセクション（自分の投稿一覧 + 新規投稿ボタン）
class MyStorySection extends ConsumerWidget {
  final VoidCallback? onAddTap;
  final void Function(List<MyWhisper> whispers, int index)? onWhisperTap;

  const MyStorySection({
    super.key,
    this.onAddTap,
    this.onWhisperTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWhispersAsync = ref.watch(myWhispersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'My Story',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: myWhispersAsync.when(
            data: (whispers) => _buildContent(whispers),
            loading: () => _buildLoading(),
            error: (_, __) => _buildError(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(List<MyWhisper> whispers) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: whispers.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AddStoryButton(
              size: 64,
              onTap: onAddTap,
            ),
          );
        }

        final whisper = whispers[index - 1];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _MyWhisperAvatar(
            whisper: whisper,
            onTap: () => onWhisperTap?.call(whispers, index - 1),
          ),
        );
      },
    );
  }

  Widget _buildLoading() {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AddStoryButton(size: 64, onTap: onAddTap),
        ),
        for (int i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildShimmer(),
          ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.bgTertiary.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 48,
          height: 12,
          decoration: BoxDecoration(
            color: AppTheme.bgTertiary.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Text(
        '読み込みに失敗しました',
        style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
      ),
    );
  }
}

/// 自分のWhisperアバター（投稿時間を表示）
class _MyWhisperAvatar extends StatelessWidget {
  final MyWhisper whisper;
  final VoidCallback? onTap;

  const _MyWhisperAvatar({
    required this.whisper,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.gradientAccent,
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.bgSecondary,
              ),
              child: Center(
                child: Icon(
                  Icons.graphic_eq_rounded,
                  color: AppTheme.accentPrimary,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 72,
            child: Text(
              _formatTime(whisper.createdAt),
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
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
