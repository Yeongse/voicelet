import 'package:freezed_annotation/freezed_annotation.dart';

part 'reward_ad_status.freezed.dart';
part 'reward_ad_status.g.dart';

@freezed
class RewardAdStatus with _$RewardAdStatus {
  const factory RewardAdStatus({
    required int remainingCount,
    required String nextResetAt,
    @Default(0) int todayClearedCount,
  }) = _RewardAdStatus;

  factory RewardAdStatus.fromJson(Map<String, dynamic> json) =>
      _$RewardAdStatusFromJson(json);
}

@freezed
class RewardAdUseResponse with _$RewardAdUseResponse {
  const factory RewardAdUseResponse({
    required bool success,
    required int clearedCount,
    required int remainingCount,
    required String nextResetAt,
  }) = _RewardAdUseResponse;

  factory RewardAdUseResponse.fromJson(Map<String, dynamic> json) =>
      _$RewardAdUseResponseFromJson(json);
}
