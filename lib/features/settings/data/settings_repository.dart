import '../domain/settings_entity.dart';
import 'settings_model.dart';

class SettingsRepository {
  final List<Map<String, dynamic>> _usersTable = [
    {
      'id': 1,
      'username': 'RASHA_KS',
      'email': 'iris@example.com',
      'password': '111',
      'created_at': DateTime(2025, 7, 20),
      'updated_at': DateTime(2026, 1, 18),
      'last_activity_at': DateTime(2026, 2, 14),
      'is_notifications_enabled': true,
      'profile_image': 'https://i.pravatar.cc/150?img=1',
    },
  ];

  Future<SettingsEntity> getSettingsData() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return SettingsModel.fromJson(_usersTable.first);
  }

  Future<SettingsEntity> toggleNotifications(bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final current = _usersTable.first;
    _usersTable[0] = {
      ...current,
      'is_notifications_enabled': enabled,
      'updated_at': DateTime.now(),
    };

    return SettingsModel.fromJson(_usersTable.first);
  }

  Future<SettingsEntity> updateAccount({
    String? username,
    String? email,
    String? password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 220));

    final current = _usersTable.first;
    _usersTable[0] = {
      ...current,
      'username': username ?? current['username'],
      'email': email ?? current['email'],
      'password': password ?? current['password'],
      'updated_at': DateTime.now(),
    };

    return SettingsModel.fromJson(_usersTable.first);
  }

  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_usersTable.isNotEmpty) {
      _usersTable.removeAt(0);
    }
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}