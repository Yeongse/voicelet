// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whisper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SignedUrlResponseImpl _$$SignedUrlResponseImplFromJson(
  Map<String, dynamic> json,
) => _$SignedUrlResponseImpl(
  signedUrl: json['signedUrl'] as String,
  bucketName: json['bucketName'] as String,
  fileName: json['fileName'] as String,
  expiresAt: json['expiresAt'] as String,
);

Map<String, dynamic> _$$SignedUrlResponseImplToJson(
  _$SignedUrlResponseImpl instance,
) => <String, dynamic>{
  'signedUrl': instance.signedUrl,
  'bucketName': instance.bucketName,
  'fileName': instance.fileName,
  'expiresAt': instance.expiresAt,
};

_$WhisperImpl _$$WhisperImplFromJson(Map<String, dynamic> json) =>
    _$WhisperImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bucketName: json['bucketName'] as String,
      fileName: json['fileName'] as String,
      duration: (json['duration'] as num).toInt(),
      createdAt: json['createdAt'] as String,
      expiresAt: json['expiresAt'] as String,
    );

Map<String, dynamic> _$$WhisperImplToJson(_$WhisperImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'bucketName': instance.bucketName,
      'fileName': instance.fileName,
      'duration': instance.duration,
      'createdAt': instance.createdAt,
      'expiresAt': instance.expiresAt,
    };

_$AudioUrlResponseImpl _$$AudioUrlResponseImplFromJson(
  Map<String, dynamic> json,
) => _$AudioUrlResponseImpl(
  signedUrl: json['signedUrl'] as String,
  expiresAt: json['expiresAt'] as String,
);

Map<String, dynamic> _$$AudioUrlResponseImplToJson(
  _$AudioUrlResponseImpl instance,
) => <String, dynamic>{
  'signedUrl': instance.signedUrl,
  'expiresAt': instance.expiresAt,
};

_$CreateWhisperResponseImpl _$$CreateWhisperResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CreateWhisperResponseImpl(
  message: json['message'] as String,
  whisper: Whisper.fromJson(json['whisper'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$CreateWhisperResponseImplToJson(
  _$CreateWhisperResponseImpl instance,
) => <String, dynamic>{
  'message': instance.message,
  'whisper': instance.whisper,
};
