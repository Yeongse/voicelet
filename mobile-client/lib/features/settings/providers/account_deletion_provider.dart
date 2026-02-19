import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../home/providers/home_providers.dart';
import '../../profile/services/profile_api_service.dart';

/// アカウント削除の状態
sealed class AccountDeletionState {
  const AccountDeletionState();
}

class AccountDeletionInitial extends AccountDeletionState {
  const AccountDeletionInitial();
}

class AccountDeletionLoading extends AccountDeletionState {
  const AccountDeletionLoading();
}

class AccountDeletionSuccess extends AccountDeletionState {
  const AccountDeletionSuccess();
}

class AccountDeletionError extends AccountDeletionState {
  final String message;
  const AccountDeletionError(this.message);
}

/// アカウント削除を管理するNotifier
class AccountDeletionNotifier extends StateNotifier<AccountDeletionState> {
  final Ref _ref;
  final ProfileApiService _profileApiService;

  AccountDeletionNotifier(this._ref)
      : _profileApiService = ProfileApiService(),
        super(const AccountDeletionInitial());

  /// 状態をリセット
  void reset() {
    state = const AccountDeletionInitial();
  }

  /// アカウントを削除
  Future<void> deleteAccount() async {
    if (state is AccountDeletionLoading) return;

    state = const AccountDeletionLoading();

    try {
      // バックエンドAPIを呼び出してアカウントを削除
      await _profileApiService.deleteAccount();

      // ローカルデータをクリア
      await _clearLocalData();

      state = const AccountDeletionSuccess();
    } catch (e) {
      String message = 'アカウント削除に失敗しました';
      if (e.toString().contains('401')) {
        message = '認証エラーが発生しました。再度ログインしてください。';
      } else if (e.toString().contains('500')) {
        message = 'サーバーエラーが発生しました。しばらく経ってから再試行してください。';
      }
      state = AccountDeletionError(message);
    }
  }

  /// ローカルデータをクリア（signOutと同様の処理）
  Future<void> _clearLocalData() async {
    // Google Sign-Inのキャッシュをクリア
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Google Sign-Inが初期化されていない場合は無視
    }

    // Supabaseからサインアウト
    await Supabase.instance.client.auth.signOut();

    // セッション中の視聴状態をクリア
    _ref.read(viewedStoryIdsProvider.notifier).state = {};
    _ref.read(viewedUserIdsProvider.notifier).state = {};

    // 認証状態をリセット
    // 注意: auth.signOutを呼ぶと重複になるため、状態のみ更新
  }
}

/// アカウント削除プロバイダー
final accountDeletionProvider =
    StateNotifierProvider<AccountDeletionNotifier, AccountDeletionState>((ref) {
  return AccountDeletionNotifier(ref);
});
