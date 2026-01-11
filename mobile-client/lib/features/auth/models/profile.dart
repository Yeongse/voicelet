import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String email,
    String? name,
    String? bio,
    String? birthMonth,
    int? age,
    String? avatarUrl,
    @Default(false) bool isPrivate,
    @Default(0) int followingCount,
    @Default(0) int followersCount,
    @Default('none') String followStatus,
    @Default(false) bool isOwnProfile,
    required String createdAt,
    required String updatedAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);
}
