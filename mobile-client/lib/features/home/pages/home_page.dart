import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../core/theme/app_theme.dart';
import '../../tutorial/configs/tutorial_content.dart';
import '../../tutorial/models/tutorial_screen.dart';
import '../../tutorial/providers/tutorial_provider.dart';
import '../models/home_models.dart';
import '../providers/home_providers.dart';
import '../widgets/my_story_section.dart';
import '../widgets/following_tab.dart';
import '../widgets/discover_tab.dart';
import '../widgets/profile_drawer.dart';

/// ホーム画面
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // チュートリアル用GlobalKeys
  final GlobalKey _myStorySectionKey = GlobalKey();
  final GlobalKey _tabBarKey = GlobalKey();
  final GlobalKey _searchButtonKey = GlobalKey();
  final GlobalKey _profileButtonKey = GlobalKey();

  bool _tutorialChecked = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 初回のみチュートリアル表示をチェック
    if (!_tutorialChecked) {
      _tutorialChecked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowTutorial();
      });
    }
  }

  void _checkAndShowTutorial() {
    final tutorialNotifier = ref.read(tutorialProvider.notifier);
    final tutorialState = ref.read(tutorialProvider);

    if (!tutorialState.isInitialized) {
      // 初期化待ち
      Future.delayed(const Duration(milliseconds: 100), _checkAndShowTutorial);
      return;
    }

    if (tutorialNotifier.shouldShowTutorial(TutorialScreen.home)) {
      _showTutorial();
    }
  }

  void _showTutorial({bool isReview = false}) {
    final targets = _buildTutorialTargets();
    if (targets.isEmpty) return;

    final tutorialNotifier = ref.read(tutorialProvider.notifier);

    if (isReview) {
      tutorialNotifier.showTutorialForReview(
        context: context,
        screen: TutorialScreen.home,
        targets: targets,
      );
    } else {
      tutorialNotifier.showTutorial(
        context: context,
        screen: TutorialScreen.home,
        targets: targets,
      );
    }
  }

  List<TargetFocus> _buildTutorialTargets() {
    const totalSteps = 5;
    return [
      TutorialContent.createTarget(
        key: _myStorySectionKey,
        identify: 'my_story',
        align: ContentAlign.bottom,
        title: 'My Story',
        description: 'あなたの声を録音して投稿できます。\n左端の「+」ボタンから新しいストーリーを作成しましょう。',
        currentStep: 0,
        totalSteps: totalSteps,
        onSkip: () => ref.read(tutorialProvider.notifier).dismiss(),
      ),
      TutorialContent.createTarget(
        key: _tabBarKey,
        identify: 'tab_bar',
        align: ContentAlign.bottom,
        title: 'フィード切り替え',
        description: '「フォロー中」でフォロー中のユーザーの投稿を、\n「おすすめ」で新しいユーザーを発見できます。',
        currentStep: 1,
        totalSteps: totalSteps,
        onSkip: () => ref.read(tutorialProvider.notifier).dismiss(),
      ),
      TutorialContent.createTarget(
        key: _searchButtonKey,
        identify: 'search',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.Circle,
        title: 'ユーザー検索',
        description: 'ユーザー名や表示名で\n他のユーザーを検索できます。',
        currentStep: 2,
        totalSteps: totalSteps,
        onSkip: () => ref.read(tutorialProvider.notifier).dismiss(),
      ),
      TutorialContent.createTarget(
        key: _profileButtonKey,
        identify: 'profile',
        align: ContentAlign.bottom,
        shape: ShapeLightFocus.Circle,
        title: 'プロフィール',
        description: 'プロフィールの確認・編集や\n各種設定にアクセスできます。',
        currentStep: 3,
        totalSteps: totalSteps,
        onSkip: () => ref.read(tutorialProvider.notifier).dismiss(),
      ),
      // 完了メッセージ
      TutorialContent.createCompletionTarget(
        identify: 'home_completion',
        currentStep: 4,
        totalSteps: totalSteps,
      ),
    ];
  }

  void _openProfileDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _navigateToRecording() {
    context.push('/recording');
  }

  void _navigateToStoryViewer(UserStory story) {
    // セッション中に視聴したストーリーIDを取得
    final viewedStoryIds = ref.read(viewedStoryIdsProvider);
    final viewedUserIds = ref.read(viewedUserIdsProvider);

    // ユーザーが全投稿視聴済みとしてマークされているか確認
    if (viewedUserIds.contains(story.user.id)) {
      _showAlreadyViewedToast();
      return;
    }

    // 未視聴のストーリーが残っているか確認
    // (サーバーからのisViewedフラグ + セッション中に視聴したストーリー)
    final hasUnviewed = story.stories.any((s) =>
        !s.isViewed && !viewedStoryIds.contains(s.id));

    if (!hasUnviewed) {
      _showAlreadyViewedToast();
      return;
    }
    context.push('/story-viewer', extra: {'story': story});
  }

  void _showAlreadyViewedToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: AppTheme.info,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'すべて視聴済みです',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToMyStoryViewer(MyWhisper whisper) {
    context.push('/my-story-viewer', extra: {
      'whisper': whisper,
    });
  }

  Future<void> _handleDiscoverUserTap(DiscoverUser user) async {
    // サーバーからのhasUnviewedとセッション中の状態を確認
    final viewedUserIds = ref.read(viewedUserIdsProvider);
    final isFullyViewedInSession = viewedUserIds.contains(user.id);
    final hasUnviewed = user.hasUnviewed && !isFullyViewedInSession;

    if (!hasUnviewed) {
      _showAlreadyViewedToast();
      return;
    }

    // おすすめユーザーのストーリーを取得して再生
    final story = await ref.read(discoverUserStoriesProvider(user.id).future);
    if (story != null && mounted) {
      _navigateToStoryViewer(story);
    }
  }

  Future<void> _handleFollowTap(DiscoverUser user) async {
    final apiService = ref.read(homeApiServiceProvider);
    try {
      await apiService.follow(followingId: user.id);
      // リストを更新
      ref.invalidate(discoverProvider);
      ref.invalidate(storiesProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'フォローに失敗しました',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            backgroundColor: AppTheme.bgElevated,
          ),
        );
      }
    }
  }

  void _navigateToUserProfile(DiscoverUser user) {
    context.push('/users/${user.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: const ProfileDrawer(),
      drawerScrimColor: Colors.black.withValues(alpha: 0.5),
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
                Container(
                  key: _myStorySectionKey,
                  child: MyStorySection(
                    onAddTap: _navigateToRecording,
                    onWhisperTap: _navigateToMyStoryViewer,
                  ),
                ),

                const SizedBox(height: 16),

                // タブバー
                Container(
                  key: _tabBarKey,
                  child: _buildTabBar(),
                ),

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
                        onUserProfileTap: _navigateToUserProfile,
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
          const SizedBox(width: 12),
          // チュートリアル復習ボタン
          GestureDetector(
            onTap: () => _showTutorial(isReview: true),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.help_outline_rounded,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 検索ボタン
          GestureDetector(
            key: _searchButtonKey,
            onTap: () => context.push('/search'),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 20,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // プロフィールボタン
          Container(
            key: _profileButtonKey,
            child: ProfileAvatarButton(
              onTap: _openProfileDrawer,
              size: 36,
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
