import 'package:freezed_annotation/freezed_annotation.dart';

part 'whisper.freezed.dart';
part 'whisper.g.dart';

/// 署名付きURLレスポンス
@freezed
class SignedUrlResponse with _$SignedUrlResponse {
  const factory SignedUrlResponse({
    required String signedUrl,
    required String bucketName,
    required String fileName,
    required String expiresAt,
  }) = _SignedUrlResponse;

  factory SignedUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$SignedUrlResponseFromJson(json);
}

/// Whisper（音声投稿）モデル
@freezed
class Whisper with _$Whisper {
  const factory Whisper({
    required String id,
    required String userId,
    required String bucketName,
    required String fileName,
    required int duration,
    required String createdAt,
    required String expiresAt,
  }) = _Whisper;

  factory Whisper.fromJson(Map<String, dynamic> json) =>
      _$WhisperFromJson(json);
}

/// 再生用署名付きURLレスポンス
@freezed
class AudioUrlResponse with _$AudioUrlResponse {
  const factory AudioUrlResponse({
    required String signedUrl,
    required String expiresAt,
  }) = _AudioUrlResponse;

  factory AudioUrlResponse.fromJson(Map<String, dynamic> json) =>
      _$AudioUrlResponseFromJson(json);
}

/// Whisper作成レスポンス
@freezed
class CreateWhisperResponse with _$CreateWhisperResponse {
  const factory CreateWhisperResponse({
    required String message,
    required Whisper whisper,
  }) = _CreateWhisperResponse;

  factory CreateWhisperResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateWhisperResponseFromJson(json);
}
