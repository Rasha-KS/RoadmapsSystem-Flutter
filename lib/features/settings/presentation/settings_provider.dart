import 'package:flutter/material.dart';
import 'package:roadmaps/core/entities/user_entity.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import '../domain/delete_account_usecase.dart';
import '../domain/get_settings_data_usecase.dart';
import '../domain/logout_usecase.dart';
import '../domain/toggle_notifications_usecase.dart';
import '../domain/upload_profile_image_usecase.dart';
import '../domain/update_account_usecase.dart';

class SettingsProvider extends ChangeNotifier {
  final GetSettingsDataUseCase getSettingsDataUseCase;
  final ToggleNotificationsUseCase toggleNotificationsUseCase;
  final UpdateAccountUseCase updateAccountUseCase;
  final UploadProfileImageUseCase uploadProfileImageUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final LogoutUseCase logoutUseCase;
  final CurrentUserProvider currentUserProvider;

  SettingsProvider({
    required this.getSettingsDataUseCase,
    required this.toggleNotificationsUseCase,
    required this.updateAccountUseCase,
    required this.uploadProfileImageUseCase,
    required this.deleteAccountUseCase,
    required this.logoutUseCase,
    required this.currentUserProvider,
  }) {
    currentUserProvider.addListener(_onCurrentUserChanged);
  }

  UserEntity? get user => currentUserProvider.user;
  bool loading = false;
  String? error;

  Future<void> loadSettings() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final current = await getSettingsDataUseCase();
      currentUserProvider.setUser(current);
    } catch (_) {
      error = 'حدث خطأ أثناء تحميل بيانات الإعدادات';
    }

    loading = false;
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    if (user == null) return;

    try {
      final updated = await toggleNotificationsUseCase(enabled);
      currentUserProvider.setUser(updated);
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
    String? profileImageUrl,
  }) async {
    if (user == null) return;

    try {
      final updated = await updateAccountUseCase(
        username: username,
        email: email,
        password: password,
        profileImageUrl: profileImageUrl,
      );
      currentUserProvider.setUser(updated);
      error = null;
      notifyListeners();
    } catch (_) {
      error = 'تعذر تحديث بيانات الحساب';
      notifyListeners();
    }
  }

  Future<void> updateProfileImage({required String localFilePath}) async {
    if (user == null) return;

    try {
      final uploadedUrl =
          await uploadProfileImageUseCase(localFilePath: localFilePath);
      final updated = await updateAccountUseCase(profileImageUrl: uploadedUrl);
      currentUserProvider.setUser(updated);
      error = null;
      notifyListeners();
    } catch (_) {
      error = 'تعذر تحديث الصورة الشخصية';
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    try {
      await deleteAccountUseCase();
      await currentUserProvider.deleteUser();
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

  void _onCurrentUserChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    currentUserProvider.removeListener(_onCurrentUserChanged);
    super.dispose();
  }
}
