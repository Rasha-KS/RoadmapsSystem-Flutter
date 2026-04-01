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
    _ensureSuccess(
      response,
      fallbackMessage: 'ØªØ¹Ø°Ø± ØªØ­Ø¯ÙŠØ« Ø­Ø§Ù„Ø© Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§Øª.',
    );
    return _resolveUpdatedUser(
      response,
      refreshFailureMessage:
          'ØªÙ… Ø­ÙØ¸ Ø­Ø§Ù„Ø© Ø§Ù„Ø¥Ø´Ø¹Ø§Ø±Ø§ØªØŒ Ù„ÙƒÙ† ØªØ¹Ø°Ø± ØªØ­Ø¯ÙŠØ« Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø­Ø§Ù„ÙŠØ§Ù‹. Ø§Ø³Ø­Ø¨ Ù„ØªØ­Ø¯ÙŠØ« Ø§Ù„ØµÙØ­Ø©.',
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
      throw const ApiException(
        'ÙŠØ±Ø¬Ù‰ Ø¥Ø¯Ø®Ø§Ù„ Ø§Ø³Ù… Ù…Ø³ØªØ®Ø¯Ù… ØµØ§Ù„Ø­.',
      );
    }

    final response = await _apiClient.put(
      ApiConstants.url(ApiConstants.updateAccount),
      body: {'username': normalizedUsername},
    );
    _ensureSuccess(
      response,
      fallbackMessage: 'ØªØ¹Ø°Ø± ØªØ­Ø¯ÙŠØ« Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø­Ø³Ø§Ø¨.',
    );
    return _resolveUpdatedUser(
      response,
      refreshFailureMessage:
          'ØªÙ… Ø­ÙØ¸ Ø§Ù„ØªØ¹Ø¯ÙŠÙ„ØŒ Ù„ÙƒÙ† ØªØ¹Ø°Ø± ØªØ­Ø¯ÙŠØ« Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø­Ø§Ù„ÙŠØ§Ù‹. Ø§Ø³Ø­Ø¨ Ù„ØªØ­Ø¯ÙŠØ« Ø§Ù„ØµÙØ­Ø©.',
    );
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final normalizedCurrentPassword = currentPassword.trim();
    if (normalizedCurrentPassword.isEmpty) {
      throw const ApiException(
        'ÙŠØ±Ø¬Ù‰ Ø¥Ø¯Ø®Ø§Ù„ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ø­Ø§Ù„ÙŠØ©.',
      );
    }

    if (newPassword.isEmpty) {
      throw const ApiException(
        'ÙŠØ±Ø¬Ù‰ Ø¥Ø¯Ø®Ø§Ù„ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø©.',
      );
    }

    if (newPasswordConfirmation.isEmpty) {
      throw const ApiException(
        'ÙŠØ±Ø¬Ù‰ ØªØ£ÙƒÙŠØ¯ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø©.',
      );
    }

    if (newPassword != newPasswordConfirmation) {
      throw const ApiException('ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± ØºÙŠØ± Ù…ØªØ·Ø§Ø¨Ù‚Ø©.');
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
      fallbackMessage: 'ØªØ¹Ø°Ø± ØªØºÙŠÙŠØ± ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±.',
      requireExplicitSuccess: true,
      missingSuccessMessage:
          'Ù„Ù… ÙŠØ¤ÙƒØ¯ Ø§Ù„Ø®Ø§Ø¯Ù… Ù†Ø¬Ø§Ø­ ØªØºÙŠÙŠØ± ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±. ÙŠØ±Ø¬Ù‰ Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.',
    );
    return _extractRequiredSuccessMessage(
      response,
      fallbackMessage:
          'Ù„Ù… ÙŠØ±Ø³Ù„ Ø§Ù„Ø®Ø§Ø¯Ù… Ø±Ø³Ø§Ù„Ø© Ù†Ø¬Ø§Ø­ Ù„ØªØ£ÙƒÙŠØ¯ ØªØºÙŠÙŠØ± ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±. ÙŠØ±Ø¬Ù‰ Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø© Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.',
    );
  }

  Future<UserEntity> uploadProfileImage({required String localFilePath}) async {
    final normalizedPath = localFilePath.trim();
    if (normalizedPath.isEmpty) {
      throw const ApiException('ÙŠØ±Ø¬Ù‰ Ø§Ø®ØªÙŠØ§Ø± ØµÙˆØ±Ø© ØµØ­ÙŠØ­Ø©.');
    }

    final file = File(normalizedPath);
    if (!await file.exists()) {
      throw const ApiException(
        'ØªØ¹Ø°Ø± Ø§Ù„Ø¹Ø«ÙˆØ± Ø¹Ù„Ù‰ Ø§Ù„ØµÙˆØ±Ø© Ø§Ù„Ù…Ø­Ø¯Ø¯Ø©.',
      );
    }

    final fileSizeInBytes = await file.length();
    const maxFileSizeInBytes = 2 * 1024 * 1024;
    if (fileSizeInBytes > maxFileSizeInBytes) {
      throw const ApiException(
        'Ø­Ø¬Ù… Ø§Ù„ØµÙˆØ±Ø© Ø£ÙƒØ¨Ø± Ù…Ù† 2 Ù…ÙŠØºØ§Ø¨Ø§ÙŠØª. Ø§Ø®ØªØ± ØµÙˆØ±Ø© Ø£ØµØºØ± Ø«Ù… Ø­Ø§ÙˆÙ„ Ù…Ø±Ø© Ø£Ø®Ø±Ù‰.',
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
        'تعذر رفع الصورة حاليًا. تحقق من الاتصال وحاول مرة أخرى.',
      );
    } on TimeoutApiException {
      throw const ApiException(
        'استغرق رفع الصورة وقتًا أطول من المعتاد. حاول مرة أخرى.',
      );
    }

    _ensureSuccess(
      response,
      fallbackMessage: 'ØªØ¹Ø°Ø± ØªØ­Ø¯ÙŠØ« Ø§Ù„ØµÙˆØ±Ø© Ø§Ù„Ø´Ø®ØµÙŠØ©.',
    );
    return _resolveUpdatedUser(
      response,
      refreshFailureMessage:
          'ØªÙ… Ø±ÙØ¹ Ø§Ù„ØµÙˆØ±Ø© Ø¨Ù†Ø¬Ø§Ø­ØŒ Ù„ÙƒÙ† ØªØ¹Ø°Ø± ØªØ­Ø¯ÙŠØ« Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª Ø­Ø§Ù„ÙŠØ§Ù‹. Ø§Ø³Ø­Ø¨ Ù„ØªØ­Ø¯ÙŠØ« Ø§Ù„ØµÙØ­Ø©.',
    );
  }

  Future<void> deleteAccount({required String password}) async {
    final normalizedPassword = password.trim();
    if (normalizedPassword.isEmpty) {
      throw const ApiException('يرجى إدخال كلمة المرور.');
    }

    final response = await _apiClient.delete(
      ApiConstants.url(ApiConstants.deleteAccount),
      body: {'password': normalizedPassword},
    );
    _ensureSuccess(response, fallbackMessage: 'تعذر حذف الحساب.');
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
            : 'ØªØ¹Ø°Ø± ØªØ³Ø¬ÙŠÙ„ Ø§Ù„Ø®Ø±ÙˆØ¬.',
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
      } on TimeoutApiException catch (error) {
        lastError = error;
        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 900));
        }
      } on ApiException catch (error) {
        lastError = error;
        break;
      }
    }

    if (lastError is NetworkException || lastError is TimeoutApiException) {
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
