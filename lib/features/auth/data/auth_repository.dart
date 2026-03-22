import 'package:flutter/foundation.dart';
import 'package:roadmaps/core/api/api_client.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/auth/token_manager.dart';
import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/core/entities/user_entity.dart';

import 'auth_model.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenManager tokenManager,
  })  : _apiClient = apiClient,
        _tokenManager = tokenManager;

  final ApiClient _apiClient;
  final TokenManager _tokenManager;

  Future<UserEntity> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.register),
      body: {
        'username': username,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final auth = AuthModel.fromResponse(response);
    await _tokenManager.saveToken(auth.token);
    return auth.user;
  }

  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.login),
      body: {
        'email': email,
        'password': password,
      },
    );

    final auth = AuthModel.fromResponse(response);
    await _tokenManager.saveToken(auth.token);
    return auth.user;
  }

  Future<UserEntity> loginWithGithub({required String code, String? state}) async {
    final response = await _apiClient.post(
      ApiConstants.url(ApiConstants.githubLogin),
      body: {
        'code': code,
        if (state != null && state.trim().isNotEmpty) 'state': state.trim(),
        'redirect_uri': ApiConstants.url(ApiConstants.githubCallback),
      },
    );

    debugPrint('GitHub login response: $response');

    final auth = AuthModel.fromResponse(response);
    await _tokenManager.saveToken(auth.token);
    return auth.user;
  }

  Future<void> forgotPassword({required String email}) async {
    await _apiClient.post(
      ApiConstants.url(ApiConstants.forgotPassword),
      body: {
        'email': email,
      },
    );
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _apiClient.post(
      ApiConstants.url(ApiConstants.resetPassword),
      body: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<void> clearSession() async {
    await _tokenManager.clearToken();
  }

  Future<String?> readToken() async {
    return _tokenManager.getToken();
  }

  Future<void> deleteTokenOnUnauthorized(ApiException exception) async {
    if (exception.statusCode == 401) {
      await _tokenManager.clearToken();
    }
  }
}
