import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../models/follow_models.dart';
import 'follow_button.dart';

class UserListTile extends ConsumerWidget {
  final UserWithFollowStatus user;
  final VoidCallback? onTap;
  final bool showRemoveButton;
  final VoidCallback? onRemove;

  const UserListTile({
    super.key,
    required this.user,
    this.onTap,
    this.showRemoveButton = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppTheme.bgTertiary,
        backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null
            ? Icon(Icons.person, color: AppTheme.textTertiary)
            : null,
      ),
      title: Row(
        children: [
          Flexible(
            child: Text(
              user.name ?? '名前未設定',
              style: TextStyle(color: AppTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (user.isPrivate) ...[
            const SizedBox(width: 4),
            Icon(Icons.lock, size: 16, color: AppTheme.textTertiary),
          ],
        ],
      ),
      subtitle: user.bio != null && user.bio!.isNotEmpty
          ? Text(
              user.bio!,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: showRemoveButton
          ? IconButton(
              icon: Icon(Icons.close, color: AppTheme.textSecondary),
              onPressed: onRemove,
            )
          : FollowButton(
              userId: user.id,
              initialStatus: user.followStatus,
              isPrivate: user.isPrivate,
              compact: true,
            ),
    );
  }
}
