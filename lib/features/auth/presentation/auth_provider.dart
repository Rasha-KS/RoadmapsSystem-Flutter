import 'package:flutter/material.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/entities/user_entity.dart';
import 'package:roadmaps/core/providers/current_user_provider.dart';
import '../domain/github_login_usecase.dart';
import '../domain/login_usecase.dart';
import '../domain/register_usecase.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.githubLoginUseCase,
    required this.currentUserProvider,
  });

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GithubLoginUseCase githubLoginUseCase;
  final CurrentUserProvider currentUserProvider;

  bool _loading = false;
  String? _error;

  bool get isLoading => _loading;
  String? get error => _error;

  Future<UserEntity?> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _error = null;

    try {
      final user = await loginUseCase(email: email, password: password);
      currentUserProvider.setUser(user);
      return user;
    } catch (e) {
      _error = _mapError(e);
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
      _error = _mapError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserEntity?> loginWithGithub({required String code}) async {
    _setLoading(true);
    _error = null;

    try {
      final user = await githubLoginUseCase(code: code);
      currentUserProvider.setUser(user);
      return user;
    } catch (e) {
      _error = _mapError(e);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  String _mapError(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
  }
}
