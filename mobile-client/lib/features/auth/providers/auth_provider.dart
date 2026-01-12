import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/api/api_client.dart';
import '../models/profile.dart';
import '../../home/providers/home_providers.dart';

/// 認証状態
sealed class AuthState {
  const AuthState();
}

class AuthStateInitial extends AuthState {
  const AuthStateInitial();
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();
}

class AuthStateUnauthenticated extends AuthState {
  const AuthStateUnauthenticated();
}

/// 認証済みだがプロフィール未登録（オンボーディングが必要）
class AuthStateNeedsOnboarding extends AuthState {
  final User user;
  const AuthStateNeedsOnboarding({required this.user});
}

/// 認証済みかつプロフィール登録済み
class AuthStateAuthenticated extends AuthState {
  final User user;
  final Profile profile;
  const AuthStateAuthenticated({required this.user, required this.profile});
}

class AuthStateError extends AuthState {
  final String message;
  const AuthStateError({required this.message});
}

/// 認証状態を管理するNotifier
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AuthStateInitial()) {
    _initialize();
  }

  SupabaseClient get _supabase => Supabase.instance.client;

  void _initialize() {
    // 認証状態変更のリスナーを設定
    _supabase.auth.onAuthStateChange.listen((data) async {
      final session = data.session;
      if (session != null) {
        await _syncWithBackend(session);
      } else {
        state = const AuthStateUnauthenticated();
      }
    });

    // 初期セッションの確認
    final session = _supabase.auth.currentSession;
    if (session != null) {
      _syncWithBackend(session);
    } else {
      state = const AuthStateUnauthenticated();
    }
  }

  /// バックエンドAPIと同期し、登録状態を確認
  Future<void> _syncWithBackend(Session session) async {
    try {
      state = const AuthStateLoading();

      final response = await ApiClient().dio.post(
        '/api/auth/callback',
        data: {'accessToken': session.accessToken},
      );

      final data = response.data as Map<String, dynamic>;
      final isRegistered = data['isRegistered'] as bool;
      final user = _supabase.auth.currentUser;

      if (user == null) {
        state = const AuthStateUnauthenticated();
        return;
      }

      if (isRegistered) {
        // 登録済みの場合はプロフィールを取得
        final profileResponse = await ApiClient().dio.get('/api/profiles/me');
        final profile =
            Profile.fromJson(profileResponse.data as Map<String, dynamic>);
        state = AuthStateAuthenticated(user: user, profile: profile);
      } else {
        // 未登録の場合はオンボーディングが必要
        state = AuthStateNeedsOnboarding(user: user);
      }
    } catch (e) {
      state = AuthStateError(message: e.toString());
    }
  }

  /// プロフィール登録完了後に呼び出す
  Future<void> completeOnboarding(Profile profile) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      state = AuthStateAuthenticated(user: user, profile: profile);
    }
  }

  /// プロフィールを更新（既存の認証状態を維持しつつプロフィールのみ更新）
  void updateProfile(Profile profile) {
    final currentState = state;
    if (currentState is AuthStateAuthenticated) {
      state = AuthStateAuthenticated(user: currentState.user, profile: profile);
    }
  }

  /// 現在のユーザーIDを取得（未認証の場合はnull）
  String? get currentUserId {
    final currentState = state;
    if (currentState is AuthStateAuthenticated) {
      return currentState.user.id;
    }
    if (currentState is AuthStateNeedsOnboarding) {
      return currentState.user.id;
    }
    return null;
  }

  /// 認証済みかどうか（プロフィール登録済み）
  bool get isAuthenticated => state is AuthStateAuthenticated;

  /// オンボーディングが必要かどうか
  bool get needsOnboarding => state is AuthStateNeedsOnboarding;

  /// アクセストークンを取得
  String? get accessToken => _supabase.auth.currentSession?.accessToken;

  /// メールアドレスとパスワードでサインアップ
  Future<void> signUp({required String email, required String password}) async {
    try {
      state = const AuthStateLoading();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.session != null) {
        await _syncWithBackend(response.session!);
      } else {
        // メール確認が必要な場合
        state = const AuthStateUnauthenticated();
      }
    } on AuthException catch (e) {
      state = AuthStateError(message: _getErrorMessage(e));
    } catch (e) {
      state = AuthStateError(message: 'サインアップに失敗しました');
    }
  }

  /// メールアドレスとパスワードでサインイン
  Future<void> signIn({required String email, required String password}) async {
    try {
      state = const AuthStateLoading();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        await _syncWithBackend(response.session!);
      } else {
        state = const AuthStateError(message: 'ログインに失敗しました');
      }
    } on AuthException catch (e) {
      state = AuthStateError(message: _getErrorMessage(e));
    } catch (e) {
      state = AuthStateError(message: 'ログインに失敗しました');
    }
  }

  /// Googleでサインイン（ネイティブ認証）
  Future<void> signInWithGoogle() async {
    try {
      state = const AuthStateLoading();

      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      final iosClientId = dotenv.env['GOOGLE_IOS_CLIENT_ID'];

      // google_sign_in v7.0+ の新しいAPI
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      // 認証を実行
      final googleUser = await googleSignIn.authenticate();

      // IDトークンを取得（authentication.idToken）
      final idToken = googleUser.authentication.idToken;

      if (idToken == null) {
        state =
            const AuthStateError(message: 'Google認証トークンの取得に失敗しました');
        return;
      }

      // Supabase側ではidTokenのみで認証可能
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (response.session != null) {
        await _syncWithBackend(response.session!);
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        state =
            const AuthStateError(message: 'Googleサインインがキャンセルされました');
      } else {
        state = AuthStateError(
            message: 'Googleサインインに失敗しました: ${e.description}');
      }
      rethrow;
    } on AuthException catch (e) {
      state = AuthStateError(message: _getErrorMessage(e));
      rethrow;
    } catch (e) {
      state = AuthStateError(
          message: 'Googleサインインに失敗しました: ${e.toString()}');
      rethrow;
    }
  }

  /// Appleでサインイン
  Future<void> signInWithApple() async {
    try {
      state = const AuthStateLoading();

      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.voicelet://login-callback/',
      );

      if (!response) {
        state =
            const AuthStateError(message: 'Appleサインインがキャンセルされました');
      }

      // OAuth認証はリダイレクトで完了するため、ここでは状態を維持
      // onAuthStateChangeで認証完了を検知
    } on AuthException catch (e) {
      state = AuthStateError(message: _getErrorMessage(e));
      rethrow;
    } catch (e) {
      state = AuthStateError(message: 'Appleサインインに失敗しました');
      rethrow;
    }
  }

  /// サインアウト
  Future<void> signOut() async {
    try {
      // Google Sign-Inのキャッシュもクリア
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {
        // Google Sign-Inが初期化されていない場合は無視
      }
      await _supabase.auth.signOut();
      state = const AuthStateUnauthenticated();
      // セッション中の視聴状態をクリア（StateProviderはAPIリクエストを発火しない）
      _ref.read(viewedStoryIdsProvider.notifier).state = {};
      _ref.read(viewedUserIdsProvider.notifier).state = {};
      // 注意: FutureProvider（myProfileProvider, storiesProvider, discoverProvider）は
      // invalidateするとAPIリクエストが発火して認証エラーになるため、ここではinvalidateしない。
      // 次回ログイン時にcurrentUserIdProviderが変わることで自動的に再取得される。
    } catch (e) {
      state = AuthStateError(message: 'ログアウトに失敗しました');
    }
  }

  /// エラーメッセージの変換
  String _getErrorMessage(AuthException e) {
    switch (e.message) {
      case 'Invalid login credentials':
        return 'メールアドレスまたはパスワードが正しくありません';
      case 'User already registered':
        return 'このメールアドレスは既に登録されています';
      case 'Email not confirmed':
        return 'メールアドレスの確認が完了していません';
      default:
        return e.message;
    }
  }
}

/// 認証プロバイダー
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

/// 現在のユーザーIDを取得するプロバイダー
final currentUserIdProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthStateAuthenticated) {
    return authState.user.id;
  }
  return null;
});

/// アクセストークンを取得するプロバイダー
final accessTokenProvider = Provider<String?>((ref) {
  final authNotifier = ref.read(authProvider.notifier);
  return authNotifier.accessToken;
});
