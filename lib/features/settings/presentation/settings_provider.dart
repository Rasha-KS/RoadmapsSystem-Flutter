import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/cache/lesson_content_cache.dart';
import 'package:roadmaps/core/cache/user_profile_cache.dart';
import 'package:roadmaps/core/entities/user_entity.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';

import '../domain/change_password_usecase.dart';
import '../domain/delete_account_usecase.dart';
import '../domain/get_settings_data_usecase.dart';
import '../domain/logout_usecase.dart';
import '../domain/toggle_notifications_usecase.dart';
import '../domain/update_account_usecase.dart';
import '../domain/upload_profile_image_usecase.dart';

class SettingsProvider extends SafeChangeNotifier {
  final GetSettingsDataUseCase getSettingsDataUseCase;
  final ToggleNotificationsUseCase toggleNotificationsUseCase;
  final UpdateAccountUseCase updateAccountUseCase;
  final ChangePasswordUseCase changePasswordUseCase;
  final UploadProfileImageUseCase uploadProfileImageUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;
  final LogoutUseCase logoutUseCase;
  final CurrentUserProvider currentUserProvider;
  final LessonContentCache _lessonContentCache = LessonContentCache.instance;
  final UserProfileCache _userProfileCache = UserProfileCache.instance;

  SettingsProvider({
    required this.getSettingsDataUseCase,
    required this.toggleNotificationsUseCase,
    required this.updateAccountUseCase,
    required this.changePasswordUseCase,
    required this.uploadProfileImageUseCase,
    required this.deleteAccountUseCase,
    required this.logoutUseCase,
    required this.currentUserProvider,
  }) {
    currentUserProvider.addListener(_onCurrentUserChanged);
  }

  UserEntity? get user => currentUserProvider.user;
  bool loading = false;
  bool togglingNotifications = false;
  bool deletingAccount = false;
  String? error;

  Future<bool> loadSettings() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      final current = await getSettingsDataUseCase();
      currentUserProvider.setUser(current);
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = _resolveErrorMessage(
        e,
        fallback: 'حدث خطأ أثناء تحميل بيانات الإعدادات.',
      );
      loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleNotifications(bool enabled) async {
    final currentUser = user;
    if (currentUser == null || togglingNotifications) {
      error = 'تعذر العثور على بيانات المستخدم الحالية.';
      notifyListeners();
      return false;
    }

    final previousUser = currentUser;
    togglingNotifications = true;
    error = null;
    currentUserProvider.setUser(
      previousUser.copyWith(isNotificationsEnabled: enabled),
    );
    notifyListeners();

    try {
      final updated = await toggleNotificationsUseCase(enabled);
      currentUserProvider.setUser(updated);
      error = null;
      return true;
    } catch (e) {
      currentUserProvider.setUser(previousUser);
      error = _resolveErrorMessage(e, fallback: 'تعذر تحديث حالة الإشعارات.');
      return false;
    } finally {
      togglingNotifications = false;
      notifyListeners();
    }
  }

  Future<bool> updateAccount({
    String? username,
    String? email,
    String? password,
    String? profileImageUrl,
  }) async {
    if (user == null) {
      error = 'تعذر العثور على بيانات المستخدم الحالية.';
      notifyListeners();
      return false;
    }

    error = null;
    notifyListeners();

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
      return true;
    } catch (e) {
      error = _resolveErrorMessage(e, fallback: 'تعذر تحديث بيانات الحساب.');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfileImage({required String localFilePath}) async {
    if (user == null) {
      error = 'تعذر العثور على بيانات المستخدم الحالية.';
      notifyListeners();
      return false;
    }

    error = null;
    notifyListeners();

    try {
      final updated = await uploadProfileImageUseCase(
        localFilePath: localFilePath,
      );
      currentUserProvider.setUser(updated);
      error = null;
      notifyListeners();
      return true;
    } catch (e) {
      error = _resolveErrorMessage(e, fallback: 'تعذر تحديث الصورة الشخصية.');
      notifyListeners();
      return false;
    }
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    if (user == null) {
      error = 'تعذر العثور على بيانات المستخدم الحالية.';
      notifyListeners();
      return null;
    }

    error = null;
    notifyListeners();

    try {
      final successMessage = await changePasswordUseCase(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      error = null;
      notifyListeners();
      return successMessage;
    } catch (e) {
      error = _resolveErrorMessage(e, fallback: 'تعذر تغيير كلمة المرور.');
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteAccount({required String password}) async {
    final normalizedPassword = password.trim();
    if (normalizedPassword.isEmpty) {
      error = 'يرجى إدخال كلمة المرور.';
      notifyListeners();
      return false;
    }

    if (deletingAccount) {
      return false;
    }

    deletingAccount = true;
    error = null;
    notifyListeners();

    try {
      await deleteAccountUseCase(password: normalizedPassword);
      await currentUserProvider.deleteUser();
      await _lessonContentCache.clearAll();
      await _userProfileCache.clearCurrentUser();
      error = null;
      return true;
    } catch (e) {
      error = _resolveErrorMessage(e, fallback: 'تعذر حذف الحساب.');
      return false;
    } finally {
      deletingAccount = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    var success = false;
    try {
      await logoutUseCase();
      success = true;
      error = null;
    } catch (e) {
      error = _resolveErrorMessage(e, fallback: 'تعذر تسجيل الخروج.');
    } finally {
      await currentUserProvider.deleteUser();
      await _lessonContentCache.clearAll();
      await _userProfileCache.clearCurrentUser();
      notifyListeners();
    }
    return success;
  }

  void clearError() {
    if (error == null) return;
    error = null;
    notifyListeners();
  }

  void _onCurrentUserChanged() {
    notifyListeners();
  }

  String _resolveErrorMessage(Object error, {required String fallback}) {
    if (error is ApiException) {
      final message = error.message.trim();
      if (message.isEmpty) {
        return fallback;
      }

      final lower = message.toLowerCase();
      final mentionsPasswordConfirmation =
          lower.contains('new_password_confirmation') ||
          lower.contains('password confirmation') ||
          lower.contains('password_confirmation');

      if (mentionsPasswordConfirmation && lower.contains('required')) {
        return 'يرجى تأكيد كلمة المرور الجديدة.';
      }
      if (lower.contains('is notifications enabled field is required') ||
          lower.contains('notifications enabled field is required')) {
        return 'حقل تفعيل الإشعارات مطلوب.';
      }
      if (lower.contains('patch method is not supported') &&
          lower.contains('update-account')) {
        return 'الخادم يتطلب استخدام PUT لتعديل الحساب.';
      }
      if (lower.contains('supported methods: put') &&
          lower.contains('update-account')) {
        return 'الخادم يتطلب استخدام PUT لتعديل الحساب.';
      }
      if (lower.contains('username') && lower.contains('required')) {
        return 'اسم المستخدم مطلوب.';
      }
      if (lower.contains('current password') &&
          (lower.contains('incorrect') ||
              lower.contains('invalid') ||
              lower.contains('wrong') ||
              lower.contains('does not match'))) {
        return 'كلمة المرور الحالية غير صحيحة.';
      }
      if (lower.contains('current password') && lower.contains('required')) {
        return 'كلمة المرور الحالية مطلوبة.';
      }
      if (lower.contains('password') &&
          (lower.contains('incorrect') ||
              lower.contains('invalid') ||
              lower.contains('wrong') ||
              lower.contains('does not match'))) {
        return 'كلمة المرور غير صحيحة.';
      }
      if ((lower.contains('new password') || lower.contains('new_password')) &&
          lower.contains('required')) {
        return 'كلمة المرور الجديدة مطلوبة.';
      }
      if (lower.contains('password') && lower.contains('required')) {
        return 'كلمة المرور مطلوبة.';
      }
      if ((lower.contains('confirmation') && lower.contains('match')) ||
          lower.contains('password confirmation') ||
          lower.contains('password_confirmation') ||
          lower.contains('confirmed') ||
          lower.contains('same as')) {
        return 'تأكيد كلمة المرور غير مطابق.';
      }
      if (RegExp(r'[a-z]').hasMatch(lower)) {
        return fallback;
      }
      return message;
    }

    return fallback;
  }

  @override
  void dispose() {
    currentUserProvider.removeListener(_onCurrentUserChanged);
    super.dispose();
  }
}
