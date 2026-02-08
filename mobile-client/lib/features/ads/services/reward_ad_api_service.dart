import '../../../core/api/api_client.dart';
import '../models/reward_ad_status.dart';

class RewardAdApiService {
  final ApiClient _apiClient = ApiClient();

  /// リワード広告ステータス取得
  Future<RewardAdStatus> getStatus() async {
    final response = await _apiClient.dio.get('/api/reward-ads/status');
    return RewardAdStatus.fromJson(response.data as Map<String, dynamic>);
  }

  /// リワード広告使用
  Future<RewardAdUseResponse> useReward() async {
    final response = await _apiClient.dio.post('/api/reward-ads/use', data: {});
    return RewardAdUseResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
