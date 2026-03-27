import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roadmaps/core/entities/user_entity.dart';

class UserProfileCache {
  UserProfileCache._({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static final UserProfileCache instance = UserProfileCache._();

  final FlutterSecureStorage _storage;

  static const String _currentUserKey = 'current_user_profile_v1';

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  Future<UserEntity?> readCurrentUser() async {
    try {
      final raw = await _storage.read(
        key: _currentUserKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      if (raw == null || raw.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return _decodeUser(decoded);
    } catch (error) {
      debugPrint('UserProfileCache.readCurrentUser error: $error');
      return null;
    }
  }

  Future<void> writeCurrentUserIfChanged(UserEntity user) async {
    try {
      final cached = await readCurrentUser();
      if (cached != null &&
          cached.username == user.username &&
          cached.profileImageUrl == user.profileImageUrl) {
        return;
      }

      await _storage.write(
        key: _currentUserKey,
        value: jsonEncode(_encodeUser(user)),
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (error) {
      debugPrint('UserProfileCache.writeCurrentUserIfChanged error: $error');
    }
  }

  Future<void> clearCurrentUser() async {
    try {
      await _storage.delete(
        key: _currentUserKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (error) {
      debugPrint('UserProfileCache.clearCurrentUser error: $error');
    }
  }

  Map<String, dynamic> _encodeUser(UserEntity user) {
    return <String, dynamic>{
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'role': user.role,
      'emailVerifiedAt': user.emailVerifiedAt?.toUtc().toIso8601String(),
      'createdAt': user.createdAt.toUtc().toIso8601String(),
      'updatedAt': user.updatedAt.toUtc().toIso8601String(),
      'lastActivityAt': user.lastActivityAt.toUtc().toIso8601String(),
      'lastLoginAt': user.lastLoginAt?.toUtc().toIso8601String(),
      'isNotificationsEnabled': user.isNotificationsEnabled,
      'profileImageUrl': user.profileImageUrl,
    };
  }

  UserEntity _decodeUser(Map<String, dynamic> data) {
    final id = _asInt(data['id']);
    final username = _asString(data['username']);
    final email = _asString(data['email']);
    final createdAt = _parseDateTime(data['createdAt']) ?? DateTime.now();
    final updatedAt = _parseDateTime(data['updatedAt']) ?? createdAt;

    return UserEntity(
      id: id,
      username: username,
      email: email,
      role: _asNullableString(data['role']),
      emailVerifiedAt: _parseDateTime(data['emailVerifiedAt']),
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastActivityAt: _parseDateTime(data['lastActivityAt']) ?? updatedAt,
      lastLoginAt: _parseDateTime(data['lastLoginAt']),
      isNotificationsEnabled: _asBool(data['isNotificationsEnabled']),
      profileImageUrl: _asNullableString(data['profileImageUrl']),
    );
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _asString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
    return fallback;
  }

  String? _asNullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final normalized = value?.toString().trim().toLowerCase();
    switch (normalized) {
      case '1':
      case 'true':
      case 'yes':
        return true;
      case '0':
      case 'false':
      case 'no':
        return false;
      default:
        return fallback;
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
