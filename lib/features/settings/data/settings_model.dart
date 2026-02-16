import 'package:roadmaps/core/entities/user_entity.dart';
import '../domain/settings_entity.dart';

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    required super.user,
    required super.isNotificationsEnabled,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      user: UserEntity(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        createdAt: json['created_at'] as DateTime,
        updatedAt: json['updated_at'] as DateTime,
        lastActivityAt: json['last_activity_at'] as DateTime,
        profileImageUrl: (json['profile_image_url'] ?? json['profile_image']) as String?,
      ),
      isNotificationsEnabled: json['is_notifications_enabled'] as bool,
    );
  }
}