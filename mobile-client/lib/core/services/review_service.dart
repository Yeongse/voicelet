import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App Storeレビュー要求サービス
///
/// 初回ユーザーが以下の両方を達成した時にレビューを要求する:
/// 1. 他のユーザーの投稿を初めて視聴
/// 2. 自分の投稿を初めて投稿
class ReviewService {
  static const _keyHasViewedFirstStory = 'has_viewed_first_story';
  static const _keyHasPostedFirstWhisper = 'has_posted_first_whisper';
  static const _keyHasRequestedReview = 'has_requested_review';

  final InAppReview _inAppReview = InAppReview.instance;

  /// 他のユーザーの投稿を初めて視聴したことを記録し、条件が揃えばレビューを要求
  Future<void> markFirstStoryViewed() async {
    final prefs = await SharedPreferences.getInstance();

    // 既に記録済みなら何もしない
    if (prefs.getBool(_keyHasViewedFirstStory) == true) {
      return;
    }

    // 初回視聴を記録
    await prefs.setBool(_keyHasViewedFirstStory, true);

    // 条件チェックしてレビュー要求
    await _checkAndRequestReview(prefs);
  }

  /// 自分の投稿を初めて投稿したことを記録し、条件が揃えばレビューを要求
  Future<void> markFirstWhisperPosted() async {
    final prefs = await SharedPreferences.getInstance();

    // 既に記録済みなら何もしない
    if (prefs.getBool(_keyHasPostedFirstWhisper) == true) {
      return;
    }

    // 初回投稿を記録
    await prefs.setBool(_keyHasPostedFirstWhisper, true);

    // 条件チェックしてレビュー要求
    await _checkAndRequestReview(prefs);
  }

  /// 両方の条件が揃っていればレビューを要求
  Future<void> _checkAndRequestReview(SharedPreferences prefs) async {
    // 既にレビュー要求済みなら何もしない
    if (prefs.getBool(_keyHasRequestedReview) == true) {
      return;
    }

    final hasViewedFirstStory = prefs.getBool(_keyHasViewedFirstStory) == true;
    final hasPostedFirstWhisper = prefs.getBool(_keyHasPostedFirstWhisper) == true;

    // 両方の条件が揃っている場合のみレビュー要求
    if (hasViewedFirstStory && hasPostedFirstWhisper) {
      // レビュー要求済みフラグを先に設定（失敗しても再度要求しないため）
      await prefs.setBool(_keyHasRequestedReview, true);

      // レビュー要求
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
      }
    }
  }

  /// 状態をリセット（デバッグ用）
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasViewedFirstStory);
    await prefs.remove(_keyHasPostedFirstWhisper);
    await prefs.remove(_keyHasRequestedReview);
  }
}

/// ReviewServiceのプロバイダー
final reviewServiceProvider = Provider<ReviewService>((ref) {
  return ReviewService();
});
