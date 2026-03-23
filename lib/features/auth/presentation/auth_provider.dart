import 'package:flutter/material.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/entities/user_entity.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import '../domain/forgot_password_usecase.dart';
import '../domain/github_login_usecase.dart';
import '../domain/login_usecase.dart';
import '../domain/register_usecase.dart';
import '../domain/reset_password_usecase.dart';

class AuthProvider extends SafeChangeNotifier {
  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.githubLoginUseCase,
    required this.forgotPasswordUseCase,
    required this.resetPasswordUseCase,
    required this.currentUserProvider,
  });

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GithubLoginUseCase githubLoginUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final CurrentUserProvider currentUserProvider;

  bool _loading = false;
  String? _error;
  int? _errorStatusCode;

  bool get isLoading => _loading;
  String? get error => _error;
  int? get errorStatusCode => _errorStatusCode;

  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;
    _errorStatusCode = null;

    try {
      final user = await loginUseCase(email: email, password: password);
      currentUserProvider.setUser(user);
      return user;
    } catch (e) {
      _setError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserEntity?> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _error = null;
    _errorStatusCode = null;

    try {
      final user = await registerUseCase(
        username: username,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      currentUserProvider.setUser(user);
      return user;
    } catch (e) {
      _setError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserEntity?> loginWithGithub({
    required String code,
    String? state,
  }) async {
    _setLoading(true);
    _error = null;
    _errorStatusCode = null;

    try {
      final user = await githubLoginUseCase(code: code, state: state);
      currentUserProvider.setUser(user);
      return user;
    } catch (e) {
      _setError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> forgotPassword({required String email}) async {
    _setLoading(true);
    _error = null;
    _errorStatusCode = null;

    try {
      await forgotPasswordUseCase(email: email);
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _error = null;
    _errorStatusCode = null;

    try {
      await resetPasswordUseCase(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return true;
    } catch (e) {
      _setError(e);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    _errorStatusCode = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(Object error) {
    if (error is ApiException) {
      _error = error.message;
      _errorStatusCode = error.statusCode;
      debugPrint(
        'Auth error${error.statusCode != null ? ' [${error.statusCode}]' : ''}: ${error.message}',
      );
      return;
    }

    _error = 'حدث خطأ غير متوقع. حاول مرة أخرى.';
    _errorStatusCode = null;
    debugPrint('Auth error: $_error');
  }
}
