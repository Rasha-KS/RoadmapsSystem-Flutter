import 'package:flutter/material.dart';
import '../domain/delete_account_usecase.dart';
import '../domain/get_settings_data_usecase.dart';
import '../domain/logout_usecase.dart';
import '../domain/settings_entity.dart';
import '../domain/toggle_notifications_usecase.dart';
import '../domain/update_account_usecase.dart';

class SettingsProvider extends ChangeNotifier {
  final GetSettingsDataUseCase getSettingsDataUseCase;
  final ToggleNotificationsUseCase toggleNotificationsUseCase;
  final UpdateAccountUseCase updateAccountUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final LogoutUseCase logoutUseCase;

  SettingsProvider({
    required this.getSettingsDataUseCase,
    required this.toggleNotificationsUseCase,
    required this.updateAccountUseCase,
    required this.deleteAccountUseCase,
    required this.logoutUseCase,
  });

  SettingsEntity? settings;
  bool loading = false;
  String? error;

  Future<void> loadSettings() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      settings = await getSettingsDataUseCase();
    } catch (_) {
      error = 'حدث خطأ أثناء تحميل بيانات الإعدادات';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    if (settings == null) return;

    try {
      settings = await toggleNotificationsUseCase(enabled);
      notifyListeners();
    } catch (_) {
      error = 'تعذر تحديث حالة الإشعارات';
      notifyListeners();
    }
  }

  Future<void> updateAccount({
    String? username,
    String? email,
    String? password,
  }) async {
    if (settings == null) return;

    try {
      settings = await updateAccountUseCase(
        username: username,
        email: email,
        password: password,
      );
      error = null;
      notifyListeners();
    } catch (_) {
      error = 'تعذر تحديث بيانات الحساب';
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    try {
      await deleteAccountUseCase();
      settings = null;
      error = null;
      notifyListeners();
    } catch (_) {
      error = 'تعذر حذف الحساب';
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      await logoutUseCase();
      error = null;
      notifyListeners();
    } catch (_) {
      error = 'تعذر تسجيل الخروج';
      notifyListeners();
    }
  }
}