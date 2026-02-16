import 'package:roadmaps/core/entities/user_entity.dart';

class SettingsEntity {
  final UserEntity user;
  final bool isNotificationsEnabled;

  const SettingsEntity({
    required this.user,
    required this.isNotificationsEnabled,
  });

  SettingsEntity copyWith({
    UserEntity? user,
    bool? isNotificationsEnabled,
  }) {
    return SettingsEntity(
      user: user ?? this.user,
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
    );
  }
}