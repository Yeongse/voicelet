import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 法的同意状態を管理するプロバイダー
/// サインアップ時にチェックボックスで同意を取得し、オンボーディング完了時にサーバーに送信
final legalConsentProvider = StateProvider<bool>((ref) => false);
