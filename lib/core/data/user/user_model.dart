import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.role,
    super.emailVerifiedAt,
    required super.createdAt,
    required super.updatedAt,
    required super.lastActivityAt,
    super.lastLoginAt,
    super.isNotificationsEnabled,
    super.profileImageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id']);
    final username = _asString(json['username']);
    final email = _asString(json['email']);

    final createdAt = _asDate(json['created_at']);
    final updatedAt = _asDate(json['updated_at']);
    final lastActiveAt = _asDate(
          json['last_active_at'] ?? json['last_activity_at'],
        ) ??
        createdAt ??
        updatedAt;

    if (id == null || username == null || email == null) {
      throw ParsingException();
    }

    final resolvedCreatedAt = createdAt ?? DateTime.now();
    final resolvedUpdatedAt = updatedAt ?? resolvedCreatedAt;

    return UserModel(
      id: id,
      username: username,
      email: email,
      role: json['role'] as String?,
      emailVerifiedAt: _asDate(json['email_verified_at']),
      createdAt: resolvedCreatedAt,
      updatedAt: resolvedUpdatedAt,
      lastActivityAt: lastActiveAt ?? resolvedUpdatedAt,
      lastLoginAt: _asDate(json['last_login_at']),
      isNotificationsEnabled:
          _asBool(json['is_notifications_enabled']) ?? false,
      profileImageUrl: (json['profile_picture'] ??
              json['profile_image_url'] ??
              json['profile_image'])
          as String?,
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String? _asString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    return null;
  }

  static DateTime? _asDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      if (value == '1' || value.toLowerCase() == 'true') return true;
      if (value == '0' || value.toLowerCase() == 'false') return false;
    }
    return null;
  }
}
