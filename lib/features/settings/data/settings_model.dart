import 'package:roadmaps/core/entities/user_entity.dart';

class SettingsModel extends UserEntity {
  const SettingsModel({
    required super.id,
    required super.username,
    required super.email,
    required super.createdAt,
    required super.updatedAt,
    required super.lastActivityAt,
    required super.isNotificationsEnabled,
    super.profileImageUrl,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      createdAt: json['created_at'] as DateTime,
      updatedAt: json['updated_at'] as DateTime,
      lastActivityAt: json['last_activity_at'] as DateTime,
      isNotificationsEnabled: json['is_notifications_enabled'] as bool,
      profileImageUrl:
          (json['profile_image_url'] ?? json['profile_image']) as String?,
    );
  }
}
