import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/dialogs.dart';
import '../../auth/providers/auth_provider.dart';
import '../models/follow_models.dart';
import '../providers/follow_provider.dart';

class FollowRequestsPage extends ConsumerStatefulWidget {
  const FollowRequestsPage({super.key});

  @override
  ConsumerState<FollowRequestsPage> createState() => _FollowRequestsPageState();
}

class _FollowRequestsPageState extends ConsumerState<FollowRequestsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // 画面表示時にキャッシュをクリアして最新データを取得
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(followRequestsProvider(1));
      ref.invalidate(sentFollowRequestsProvider(1));
      ref.invalidate(followRequestCountProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppTheme.bgSecondary,
        foregroundColor: AppTheme.textPrimary,
        title: const Text('フォローリクエスト'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentPrimary,
          labelColor: AppTheme.accentPrimary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: '受信'),
            Tab(text: '送信中'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ReceivedRequestsTab(),
          _SentRequestsTab(),
        ],
      ),
    );
  }
}

/// 成功トーストを表示
void _showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppTheme.accentPrimary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.bgElevated.withValues(alpha: 0.95),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
    ),
  );
}

/// エラートーストを表示
void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
      backgroundColor: AppTheme.bgElevated.withValues(alpha: 0.95),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
    ),
  );
}

/// 受信したフォローリクエスト一覧
class _ReceivedRequestsTab extends ConsumerStatefulWidget {
  const _ReceivedRequestsTab();

  @override
  ConsumerState<_ReceivedRequestsTab> createState() => _ReceivedRequestsTabState();
}

class _ReceivedRequestsTabState extends ConsumerState<_ReceivedRequestsTab> {
  final List<String> _removedIds = [];

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(followRequestsProvider(1));

    return asyncValue.when(
      data: (response) {
        // 削除済みのIDを除外
        final requests = response.data.where((r) => !_removedIds.contains(r.id)).toList();

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textTertiary),
                const SizedBox(height: 16),
                Text(
                  'フォローリクエストはありません',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _removedIds.clear();
            ref.invalidate(followRequestsProvider(1));
            ref.invalidate(followRequestCountProvider);
          },
          child: ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _ReceivedRequestTile(
                key: ValueKey(request.id),
                request: request,
                onRemoved: () {
                  setState(() {
                    _removedIds.add(request.id);
                  });
                  ref.invalidate(followRequestCountProvider);
                },
              );
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: AppTheme.accentPrimary),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text('エラーが発生しました', style: TextStyle(color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _removedIds.clear();
                ref.invalidate(followRequestsProvider(1));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 受信リクエストタイル
class _ReceivedRequestTile extends ConsumerStatefulWidget {
  final FollowRequest request;
  final VoidCallback onRemoved;

  const _ReceivedRequestTile({
    super.key,
    required this.request,
    required this.onRemoved,
  });

  @override
  ConsumerState<_ReceivedRequestTile> createState() => _ReceivedRequestTileState();
}

class _ReceivedRequestTileState extends ConsumerState<_ReceivedRequestTile> {
  bool _isLoading = false;

  Future<void> _handleAction(Future<void> Function() action, String successMessage, String errorMessage) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await action();
      if (mounted) {
        widget.onRemoved();
        _showSuccessSnackBar(context, successMessage);
      }
    } catch (e) {
      debugPrint('Action error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(context, errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final requester = widget.request.requester;

    return ListTile(
      onTap: () => context.push('/users/${requester.id}'),
      leading: CircleAvatar(
        backgroundColor: AppTheme.bgTertiary,
        backgroundImage:
            requester.avatarUrl != null ? NetworkImage(requester.avatarUrl!) : null,
        child: requester.avatarUrl == null
            ? Icon(Icons.person, color: AppTheme.textTertiary)
            : null,
      ),
      title: Text(
        requester.name ?? '名前未設定',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
      subtitle: Text(
        'フォローリクエスト',
        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      trailing: _isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppTheme.accentPrimary,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check_circle, color: AppTheme.success),
                  onPressed: () {
                    final service = ref.read(followApiServiceProvider);
                    final currentUserId = ref.read(currentUserIdProvider);
                    _handleAction(
                      () async {
                        await service.approveRequest(widget.request.id);
                        // 自分のフォロワー数を+1
                        if (currentUserId != null) {
                          adjustFollowCount(ref, currentUserId, followersDelta: 1);
                        }
                      },
                      'リクエストを承認しました',
                      '承認に失敗しました',
                    );
                  },
                  tooltip: '承認',
                ),
                IconButton(
                  icon: Icon(Icons.cancel, color: AppTheme.error),
                  onPressed: () {
                    final service = ref.read(followApiServiceProvider);
                    _handleAction(
                      () => service.rejectRequest(widget.request.id),
                      'リクエストを拒否しました',
                      '拒否に失敗しました',
                    );
                  },
                  tooltip: '拒否',
                ),
              ],
            ),
    );
  }
}

/// 送信済みフォローリクエスト一覧
class _SentRequestsTab extends ConsumerStatefulWidget {
  const _SentRequestsTab();

  @override
  ConsumerState<_SentRequestsTab> createState() => _SentRequestsTabState();
}

class _SentRequestsTabState extends ConsumerState<_SentRequestsTab> {
  final List<String> _removedIds = [];

  @override
  Widget build(BuildContext context) {
    final asyncValue = ref.watch(sentFollowRequestsProvider(1));

    return asyncValue.when(
      data: (response) {
        // 削除済みのIDを除外
        final requests = response.data.where((r) => !_removedIds.contains(r.id)).toList();

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_outlined, size: 64, color: AppTheme.textTertiary),
                const SizedBox(height: 16),
                Text(
                  '送信中のリクエストはありません',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _removedIds.clear();
            ref.invalidate(sentFollowRequestsProvider(1));
          },
          child: ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _SentRequestTile(
                key: ValueKey(request.id),
                request: request,
                onRemoved: () {
                  setState(() {
                    _removedIds.add(request.id);
                  });
                },
              );
            },
          ),
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: AppTheme.accentPrimary),
      ),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.error),
            const SizedBox(height: 16),
            Text('エラーが発生しました', style: TextStyle(color: AppTheme.textPrimary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _removedIds.clear();
                ref.invalidate(sentFollowRequestsProvider(1));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 送信済みリクエストタイル
class _SentRequestTile extends ConsumerStatefulWidget {
  final SentFollowRequest request;
  final VoidCallback onRemoved;

  const _SentRequestTile({
    super.key,
    required this.request,
    required this.onRemoved,
  });

  @override
  ConsumerState<_SentRequestTile> createState() => _SentRequestTileState();
}

class _SentRequestTileState extends ConsumerState<_SentRequestTile> {
  bool _isLoading = false;

  Future<void> _cancel() async {
    final confirmed = await showDestructiveConfirmDialog(
      context: context,
      message: 'フォローリクエストを取り消しますか？',
      destructiveText: 'リクエストを取消',
    );

    if (!confirmed) return;

    setState(() => _isLoading = true);
    try {
      final service = ref.read(followApiServiceProvider);
      await service.cancelRequest(widget.request.id);
      if (mounted) {
        widget.onRemoved();
        _showSuccessSnackBar(context, 'リクエストを取り消しました');
      }
    } catch (e) {
      debugPrint('Cancel error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(context, 'エラーが発生しました');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = widget.request.target;

    return ListTile(
      onTap: () => context.push('/users/${target.id}'),
      leading: CircleAvatar(
        backgroundColor: AppTheme.bgTertiary,
        backgroundImage: target.avatarUrl != null ? NetworkImage(target.avatarUrl!) : null,
        child: target.avatarUrl == null
            ? Icon(Icons.person, color: AppTheme.textTertiary)
            : null,
      ),
      title: Text(
        target.name ?? '名前未設定',
        style: TextStyle(color: AppTheme.textPrimary),
      ),
      subtitle: Text(
        '承認待ち',
        style: TextStyle(color: AppTheme.textTertiary, fontSize: 12),
      ),
      trailing: _isLoading
          ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentPrimary),
            )
          : TextButton(
              onPressed: _cancel,
              child: Text(
                '取消',
                style: TextStyle(color: AppTheme.error),
              ),
            ),
    );
  }
}
