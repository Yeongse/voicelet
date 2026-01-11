import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 認証状態
sealed class AuthState {
  const AuthState();
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

class AuthStateAuthenticated extends AuthState {
  final String userId;
  const AuthStateAuthenticated({required this.userId});
}

/// 認証状態を管理するNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  /// 開発用デモユーザーID（ローカルのみ）
  static const String demoUserId = 'demo-user-001';

  AuthNotifier() : super(const AuthStateAuthenticated(userId: demoUserId));

  /// 現在のユーザーIDを取得（未認証の場合はnull）
  String? get currentUserId {
    final state = this.state;
    if (state is AuthStateAuthenticated) {
      return state.userId;
    }
    return null;
  }

  /// 認証済みかどうか
  bool get isAuthenticated => state is AuthStateAuthenticated;
}

/// 認証プロバイダー
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// 現在のユーザーIDを取得するプロバイダー
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthStateAuthenticated) {
    return authState.userId;
  }
  return null;
});
