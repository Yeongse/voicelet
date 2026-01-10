import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ホーム画面用タイムラインデータの取得プロバイダー
///
/// 現在はモックデータを返却。本番APIが実装され次第、
/// ApiClientを使用した実装に置き換える。
final homeDataProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  // TODO: 本番API実装後に置き換え
  // final apiClient = ref.read(apiClientProvider);
  // return await apiClient.get('/api/timeline');

  // モックデータ: 実際のAPIレスポンスを模倣
  await Future.delayed(const Duration(milliseconds: 500));
  return [
    {'id': '1', 'title': 'Sample Voice 1', 'duration': 15},
    {'id': '2', 'title': 'Sample Voice 2', 'duration': 20},
    {'id': '3', 'title': 'Sample Voice 3', 'duration': 10},
  ];
});
