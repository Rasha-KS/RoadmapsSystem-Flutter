import 'dart:async';
import 'dart:io';

import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/core/data/user/user_model.dart';
import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/core/entities/user_entity.dart';

class SettingsRepository {
  SettingsRepository({
    required UserRepository userRepository,
    required ApiClient apiClient,
  }) : _userRepository = userRepository,
       _apiClient = apiClient;

  final UserRepository _userRepository;
  final ApiClient _apiClient;

  Future<UserEntity> getSettingsData() async {
    return _userRepository.getCurrentUser();
  }

  Future<UserEntity> toggleNotifications(bool enabled) async {
    final response = await _apiClient.patch(
      ApiConstants.url(ApiConstants.myNotifications),
      body: {
        'notifications_enabled': enabled,
        'is_notifications_enabled': enabled,
      },
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحديث حالة الإشعارات.');
    return _resolveUpdatedUser(
      response,
      refreshFailureMessage:
          'تم حفظ حالة الإشعارات، لكن تعذر تحديث البيانات حالياً. اسحب لتحديث الصفحة.',
    );
  }

  Future<UserEntity> updateAccount({
    String? username,
    String? email,
    String? password,
    String? profileImageUrl,
  }) async {
    final _ = (email, password, profileImageUrl);
    final normalizedUsername = username?.trim();
    if (normalizedUsername == null || normalizedUsername.isEmpty) {
      throw const ApiException('يرجى إدخال اسم مستخدم صالح.');
    }

    final response = await _apiClient.put(
      ApiConstants.url(ApiConstants.updateAccount),
      body: {'username': normalizedUsername},
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر تحديث بيانات الحساب.');
    return _resolveUpdatedUser(
      response,
      refreshFailureMessage:
          'تم حفظ التعديل، لكن تعذر تحديث البيانات حالياً. اسحب لتحديث الصفحة.',
    );
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final normalizedCurrentPassword = currentPassword.trim();
    if (normalizedCurrentPassword.isEmpty) {
      throw const ApiException('يرجى إدخال كلمة المرور الحالية.');
    }

    if (newPassword.isEmpty) {
      throw const ApiException('يرجى إدخال كلمة المرور الجديدة.');
    }

    if (newPasswordConfirmation.isEmpty) {
      throw const ApiException('يرجى تأكيد كلمة المرور الجديدة.');
    }

    if (newPassword != newPasswordConfirmation) {
      throw const ApiException('كلمة المرور غير متطابقة.');
    }

    final response = await _apiClient.put(
      ApiConstants.url(ApiConstants.updateAccount),
      body: {
        'current_password': normalizedCurrentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );
    _ensureSuccess(
      response,
      fallbackMessage: 'تعذر تغيير كلمة المرور.',
      requireExplicitSuccess: true,
      missingSuccessMessage:
          'لم يؤكد الخادم نجاح تغيير كلمة المرور. يرجى المحاولة مرة أخرى.',
    );
    return _extractRequiredSuccessMessage(
      response,
      fallbackMessage:
          'لم يرسل الخادم رسالة نجاح لتأكيد تغيير كلمة المرور. يرجى المحاولة مرة أخرى.',
    );
  }

  Future<UserEntity> uploadProfileImage({required String localFilePath}) async {
    final normalizedPath = localFilePath.trim();
    if (normalizedPath.isEmpty) {
      throw const ApiException('يرجى اختيار صورة صحيحة.');
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      throw const ApiException('تعذر العثور على الصورة المحددة.');
    }

    final fileSizeInBytes = await file.length();
    const maxFileSizeInBytes = 2 * 1024 * 1024;
    if (fileSizeInBytes > maxFileSizeInBytes) {
      throw const ApiException(
        'حجم الصورة أكبر من 2 ميغابايت. اختر صورة أصغر ثم حاول مرة أخرى.',
      );
    }

    late final Map<String, dynamic> response;
    try {
      response = await _apiClient.postMultipart(
        ApiConstants.url(ApiConstants.updateProfilePicture),
        fileField: 'profile_picture',
        filePath: normalizedPath,
        timeout: const Duration(seconds: 60),
      );
    } on NetworkException {
      throw const ApiException(
        'تعذر رفع الصورة حالياً. تحقق من الاتصال وحاول مرة أخرى.',
      );
    }

    _ensureSuccess(response, fallbackMessage: 'تعذر تحديث الصورة الشخصية.');
    return _resolveUpdatedUser(
      response,
      refreshFailureMessage:
          'تم رفع الصورة بنجاح، لكن تعذر تحديث البيانات حالياً. اسحب لتحديث الصفحة.',
    );
  }

  Future<void> deleteAccount() async {
    await _userRepository.deleteCurrentUser();
  }

  Future<void> logout() async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.logout),
    );

    if (response['success'] != true) {
      final message = response['message'];
      throw ApiException(
        message is String && message.trim().isNotEmpty
            ? message.trim()
            : 'تعذر تسجيل الخروج.',
      );
    }
  }

  Future<UserEntity> _resolveUpdatedUser(
    Map<String, dynamic> response, {
    required String refreshFailureMessage,
  }) async {
    final embeddedUser = _extractUserFromResponse(response);
    if (embeddedUser != null) {
      return embeddedUser;
    }

    ApiException? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await _userRepository.getCurrentUser();
      } on NetworkException catch (error) {
        lastError = error;
        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 900));
        }
      } on ApiException catch (error) {
        lastError = error;
        break;
      }
    }

    if (lastError is NetworkException) {
      throw ApiException(refreshFailureMessage);
    }

    throw lastError ?? ApiException(refreshFailureMessage);
  }

  UserEntity? _extractUserFromResponse(Map<String, dynamic> response) {
    final data = response['data'];
    final candidates = <dynamic>[
      response['user'],
      data,
      if (data is Map<String, dynamic>) ...[
        data['user'],
        data['account'],
        data['profile'],
      ],
    ];

    for (final candidate in candidates) {
      if (candidate is! Map<String, dynamic>) continue;
      try {
        return UserModel.fromJson(candidate);
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  void _ensureSuccess(
    Map<String, dynamic> response, {
    required String fallbackMessage,
    bool requireExplicitSuccess = false,
    String? missingSuccessMessage,
  }) {
    if (requireExplicitSuccess && response['success'] != true) {
      final message = response['message'];
      throw ApiException(
        message is String && message.trim().isNotEmpty
            ? message.trim()
            : (missingSuccessMessage ?? fallbackMessage),
      );
    }

    if (response.containsKey('success') && response['success'] != true) {
      final message = response['message'];
      throw ApiException(
        message is String && message.trim().isNotEmpty
            ? message.trim()
            : fallbackMessage,
      );
    }
  }

  String _extractRequiredSuccessMessage(
    Map<String, dynamic> response, {
    required String fallbackMessage,
  }) {
    final data = response['data'];
    final candidates = <dynamic>[
      response['message'],
      if (data is String) data,
      if (data is Map<String, dynamic>) data['message'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    throw ApiException(fallbackMessage);
  }
}
