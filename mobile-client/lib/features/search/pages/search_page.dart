import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../follow/models/follow_models.dart';
import '../../follow/widgets/follow_button.dart';
import '../models/search_user.dart';
import '../providers/search_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      ref.read(searchQueryProvider.notifier).update(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.bgElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'ユーザーを検索...',
              hintStyle: TextStyle(color: AppTheme.textTertiary),
              border: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchQueryProvider.notifier).clear();
              },
            ),
        ],
      ),
      body: query.isEmpty
          ? Center(
              child: Text(
                'ユーザー名や表示名で検索できます',
                style: TextStyle(color: AppTheme.textTertiary),
              ),
            )
          : _SearchResults(query: query),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchAsync = ref.watch(
      searchUsersProvider(query: query),
    );

    return searchAsync.when(
      data: (response) {
        if (response.data.isEmpty) {
          return Center(
            child: Text(
              '該当するユーザーが見つかりませんでした',
              style: TextStyle(color: AppTheme.textTertiary),
            ),
          );
        }

        return ListView.builder(
          itemCount: response.data.length,
          itemBuilder: (context, index) {
            final user = response.data[index];
            return _SearchResultTile(user: user);
          },
        );
      },
      loading: () => Center(
        child: CircularProgressIndicator(color: AppTheme.accentPrimary),
      ),
      error: (error, stack) => Center(
        child: Text(
          'エラーが発生しました: $error',
          style: TextStyle(color: AppTheme.error),
        ),
      ),
    );
  }
}

class _SearchResultTile extends ConsumerWidget {
  const _SearchResultTile({required this.user});

  final SearchUser user;

  FollowStatus _parseFollowStatus(String status) {
    switch (status) {
      case 'following':
        return FollowStatus.following;
      case 'requested':
        return FollowStatus.requested;
      default:
        return FollowStatus.none;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final isOwnProfile = currentUserId == user.id;
    final followStatus = _parseFollowStatus(user.followStatus);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.bgElevated,
        backgroundImage:
            user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Text(
                (user.name ?? user.username ?? '?')[0].toUpperCase(),
                style: TextStyle(color: AppTheme.textPrimary),
              )
            : null,
      ),
      title: Row(
        children: [
          if (user.isPrivate) ...[
            Icon(Icons.lock, size: 14, color: AppTheme.textTertiary),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              user.name ?? 'No Name',
              style: TextStyle(color: AppTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: user.username != null
          ? Text(
              '@${user.username}',
              style: TextStyle(color: AppTheme.textSecondary),
            )
          : null,
      trailing: isOwnProfile
          ? null
          : FollowButton(
              userId: user.id,
              initialStatus: followStatus,
              isPrivate: user.isPrivate,
              compact: true,
            ),
      onTap: () {
        context.push('/users/${user.id}');
      },
    );
  }
}
