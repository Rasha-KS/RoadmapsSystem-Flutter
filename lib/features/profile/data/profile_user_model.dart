import 'package:roadmaps/core/entities/user_entity.dart';

class ProfileUserModel extends UserEntity {
  ProfileUserModel({
    required super.id,
    required super.username,
    required super.email,
    required super.createdAt,
    required super.updatedAt,
    required super.lastActivityAt,
    super.profileImageUrl,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      createdAt: json['created_at'] as DateTime,
      updatedAt: json['updated_at'] as DateTime,
      lastActivityAt: json['last_activity_at'] as DateTime,
      profileImageUrl:
          (json['profile_image_url'] ?? json['profile_image']) as String?,
    );
  }
}

