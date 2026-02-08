// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reward_ad_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RewardAdStatusImpl _$$RewardAdStatusImplFromJson(Map<String, dynamic> json) =>
    _$RewardAdStatusImpl(
      remainingCount: (json['remainingCount'] as num).toInt(),
      nextResetAt: json['nextResetAt'] as String,
      todayClearedCount: (json['todayClearedCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RewardAdStatusImplToJson(
  _$RewardAdStatusImpl instance,
) => <String, dynamic>{
  'remainingCount': instance.remainingCount,
  'nextResetAt': instance.nextResetAt,
  'todayClearedCount': instance.todayClearedCount,
};

_$RewardAdUseResponseImpl _$$RewardAdUseResponseImplFromJson(
  Map<String, dynamic> json,
) => _$RewardAdUseResponseImpl(
  success: json['success'] as bool,
  clearedCount: (json['clearedCount'] as num).toInt(),
  remainingCount: (json['remainingCount'] as num).toInt(),
  nextResetAt: json['nextResetAt'] as String,
);

Map<String, dynamic> _$$RewardAdUseResponseImplToJson(
  _$RewardAdUseResponseImpl instance,
) => <String, dynamic>{
  'success': instance.success,
  'clearedCount': instance.clearedCount,
  'remainingCount': instance.remainingCount,
  'nextResetAt': instance.nextResetAt,
};
