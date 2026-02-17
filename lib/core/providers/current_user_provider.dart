import 'package:flutter/material.dart';
import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/core/entities/user_entity.dart';

class CurrentUserProvider extends ChangeNotifier {
  CurrentUserProvider({required UserRepository userRepository})
      : _userRepository = userRepository;

  final UserRepository _userRepository;
  UserEntity? _currentUser;
  bool _loading = false;

  UserEntity? get user => _currentUser;
  int? get userId => _currentUser?.id;
  bool get isLoading => _loading;

  Future<void> loadCurrentUser() async {
    _loading = true;
    notifyListeners();

    _currentUser = await _userRepository.getCurrentUser();

    _loading = false;
    notifyListeners();
  }

  Future<void> updateUser({
    String? username,
    String? email,
    String? password,
    String? profileImageUrl,
    bool? isNotificationsEnabled,
  }) async {
    _currentUser = await _userRepository.updateCurrentUser(
      username: username,
      email: email,
      password: password,
      profileImageUrl: profileImageUrl,
      isNotificationsEnabled: isNotificationsEnabled,
    );
    notifyListeners();
  }

  void setUser(UserEntity user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> deleteUser() async {
    await _userRepository.deleteCurrentUser();
    _currentUser = null;
    notifyListeners();
  }
}
