import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../../../core/theme/app_theme.dart';
import '../../ads/providers/ad_provider.dart';
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
  final GlobalKey _feedAreaKey = GlobalKey();
  final GlobalKey _searchButtonKey = GlobalKey();
  final GlobalKey _profileButtonKey = GlobalKey();

  bool _tutorialChecked = false;
  bool _isNavigatingToViewer = false;

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
    const totalSteps = 6;
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
        key: _feedAreaKey,
        identify: 'feed_area',
        align: ContentAlign.top,
        title: '投稿を視聴',
        description: 'ユーザーのアイコンをタップすると、\nその人の投稿を視聴できます。\n\n※ 各投稿は1回しか視聴できません。',
        currentStep: 2,
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
        currentStep: 3,
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
        currentStep: 4,
        totalSteps: totalSteps,
        onSkip: () => ref.read(tutorialProvider.notifier).dismiss(),
      ),
      // 完了メッセージ
      TutorialContent.createCompletionTarget(
        identify: 'home_completion',
        currentStep: 5,
        totalSteps: totalSteps,
      ),
    ];
  }

  void _openProfileDrawer() {
    // ドロワーを開く前に広告ステータスを再取得
    ref.read(rewardAdStatusProvider.notifier).fetchStatus();
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _navigateToRecording() {
    context.push('/recording');
  }

  void _navigateToStoryViewer(UserStory story) {
    if (_isNavigatingToViewer) return;

    final viewedStoryIds = ref.read(viewedStoryIdsProvider);

    // 個別ストーリーの視聴状態で判定（サーバー + セッション内）
    // ※ viewedUserIdsは使わない（新規投稿追加時にサーバーデータと矛盾するため）
    final allStoriesViewed = story.stories.every(
      (s) => s.isViewed || viewedStoryIds.contains(s.id),
    );

    if (allStoriesViewed) {
      _showAlreadyViewedToast();
      return;
    }

    setState(() => _isNavigatingToViewer = true);
    context.push('/story-viewer', extra: {'story': story}).then((_) {
      if (mounted) {
        setState(() => _isNavigatingToViewer = false);
        // ストーリービューワーから戻った時にデータを再取得
        ref.invalidate(storiesProvider);
        ref.invalidate(discoverProvider);
      }
    });
  }

  void _showAlreadyViewedToast() {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (context, ref, _) {
          final statusAsync = ref.watch(rewardAdStatusProvider);

          return statusAsync.when(
            data: (status) {
              final remainingCount = status.remainingCount;
              return CupertinoAlertDialog(
                title: const Text('視聴済み'),
                content: Text(
                  remainingCount > 0
                      ? 'このユーザーの投稿はすべて視聴済みです。\n\n動画広告を視聴して、視聴回数を回復しますか？\n（本日残り$remainingCount回）'
                      : 'このユーザーの投稿はすべて視聴済みです。\n\n本日の広告視聴上限に達しました。\n（朝5時(JST)に回復します）',
                ),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: const Text('閉じる'),
                  ),
                  if (remainingCount > 0)
                    CupertinoDialogAction(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        _handleWatchAd();
                      },
                      child: const Text('広告を見る'),
                    ),
                ],
              );
            },
            loading: () => CupertinoAlertDialog(
              title: const Text('視聴済み'),
              content: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CupertinoActivityIndicator(),
                  SizedBox(width: 16),
                  Text('読み込み中...'),
                ],
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
            error: (_, _) => CupertinoAlertDialog(
              title: const Text('視聴済み'),
              content: const Text('このユーザーの投稿はすべて視聴済みです。'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('閉じる'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleWatchAd() async {
    final adService = ref.read(adServiceProvider);
    final statusNotifier = ref.read(rewardAdStatusProvider.notifier);

    // ローディングダイアログを表示
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('広告を読み込み中...'),
          ],
        ),
      ),
    );

    // 広告がロードされていなければプリロードを待つ
    if (!adService.isRewardedAdReady) {
      await adService.preloadRewardedAd();

      if (!adService.isRewardedAdReady) {
        if (mounted) {
          Navigator.of(context).pop(); // ローディングダイアログを閉じる
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('広告の読み込みに失敗しました'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
        return;
      }
    }

    if (mounted) {
      Navigator.of(context).pop(); // ローディングダイアログを閉じる
    }

    try {
      // 広告を表示
      final earnedReward = await adService.showRewardedAd();

      if (!earnedReward) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('広告の視聴が完了しませんでした')),
          );
        }
        return;
      }

      // 視聴完了 → APIを呼び出して履歴をクリア
      final response = await statusNotifier.useReward();

      if (response != null && mounted) {
        // ローカルの視聴状態をクリア
        ref.read(viewedStoryIdsProvider.notifier).state = {};
        ref.read(viewedUserIdsProvider.notifier).state = {};

        // ストーリーリストを更新
        ref.invalidate(storiesProvider);
        ref.invalidate(discoverProvider);

        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('視聴履歴をクリア'),
            content: Text('${response.clearedCount}件の視聴履歴をクリアしました。\nもう一度投稿を視聴できます！'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('エラーが発生しました'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _navigateToMyStoryViewer(MyWhisper whisper) {
    context.push('/my-story-viewer', extra: {
      'whisper': whisper,
    });
  }

  Future<void> _handleDiscoverUserTap(DiscoverUser user) async {
    if (_isNavigatingToViewer) return;

    // 投稿がない場合は何もしない
    if (user.whisperCount == 0) {
      return;
    }

    // サーバーからのhasUnviewedで判定（viewedUserIdsは使わない）
    if (!user.hasUnviewed) {
      _showAlreadyViewedToast();
      return;
    }

    setState(() => _isNavigatingToViewer = true);
    try {
      final story = await ref.read(discoverUserStoriesProvider(user.id).future);
      if (story != null && mounted) {
        // 取得したストーリーも視聴済みかチェック
        final viewedStoryIds = ref.read(viewedStoryIdsProvider);
        final allStoriesViewed = story.stories.every(
          (s) => s.isViewed || viewedStoryIds.contains(s.id),
        );

        if (allStoriesViewed) {
          _showAlreadyViewedToast();
          return;
        }

        await context.push('/story-viewer', extra: {'story': story});
      }
    } finally {
      if (mounted) {
        setState(() => _isNavigatingToViewer = false);
        // ストーリービューワーから戻った時にデータを再取得
        ref.invalidate(storiesProvider);
        ref.invalidate(discoverProvider);
      }
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
                  key: _feedAreaKey,
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
          // ローディングオーバーレイ（視聴画面遷移中）
          if (_isNavigatingToViewer)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.accentPrimary,
                ),
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
