import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/home_models.dart';
import '../providers/home_providers.dart';
import '../widgets/my_story_section.dart';
import '../widgets/following_tab.dart';
import '../widgets/discover_tab.dart';
import '../../auth/providers/auth_provider.dart';

/// ホーム画面
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToRecording() {
    context.push('/recording');
  }

  void _navigateToStoryViewer(UserStory story) {
    context.push('/story-viewer', extra: {'story': story});
  }

  void _navigateToMyStoryViewer(List<MyWhisper> whispers, int index) {
    context.push('/my-story-viewer', extra: {
      'whispers': whispers,
      'initialIndex': index,
    });
  }

  Future<void> _handleDiscoverUserTap(DiscoverUser user) async {
    // おすすめユーザーのストーリーを取得して再生
    final story = await ref.read(discoverUserStoriesProvider(user.id).future);
    if (story != null && mounted) {
      _navigateToStoryViewer(story);
    }
  }

  Future<void> _handleFollowTap(DiscoverUser user) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final apiService = ref.read(homeApiServiceProvider);
    try {
      await apiService.follow(followerId: userId, followingId: user.id);
      // リストを更新
      ref.invalidate(discoverProvider);
      ref.invalidate(storiesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('フォローに失敗しました'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.5),
                ],
                stops: const [0.0, 0.2, 0.8, 1.0],
              ),
            ),
          ),
          // コンテンツ
          SafeArea(
            child: Column(
              children: [
                // ヘッダー
                _buildHeader(),

                // My Storyセクション
                const SizedBox(height: 8),
                MyStorySection(
                  onAddTap: _navigateToRecording,
                  onWhisperTap: _navigateToMyStoryViewer,
                ),

                const SizedBox(height: 16),

                // タブバー
                _buildTabBar(),

                // タブコンテンツ
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      FollowingTab(
                        onStoryTap: _navigateToStoryViewer,
                      ),
                      DiscoverTab(
                        onUserStoryTap: _handleDiscoverUserTap,
                        onFollowTap: _handleFollowTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Voicelet',
            style: TextStyle(
              fontFamily: 'Quicksand',
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
          const Spacer(),
          // 開発用ボタン
          GestureDetector(
            onTap: () => context.go('/dev/whispers'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.warning.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.developer_mode_rounded,
                    size: 14,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'DEV',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.warning,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgSecondary.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppTheme.gradientAccent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd - 2),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: AppTheme.textInverse,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'フォロー中'),
          Tab(text: 'おすすめ'),
        ],
      ),
    );
  }
}
