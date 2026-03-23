import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import 'package:roadmaps/core/entities/user_entity.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';

class CurrentUserProvider extends SafeChangeNotifier {
  CurrentUserProvider({required UserRepository userRepository})
      : _userRepository = userRepository;

  final UserRepository _userRepository;
  UserEntity? _currentUser;
  bool _loading = false;
  String? _error;

  UserEntity? get user => _currentUser;
  int? get userId => _currentUser?.id;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadCurrentUser() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _userRepository.getCurrentUser();
    } catch (e) {
      _currentUser = null;
      _error = e.toString();
    }

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
    try {
      _currentUser = await _userRepository.updateCurrentUser(
        username: username,
        email: email,
        password: password,
        profileImageUrl: profileImageUrl,
        isNotificationsEnabled: isNotificationsEnabled,
      );
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }

  void setUser(UserEntity user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> deleteUser() async {
    try {
      await _userRepository.deleteCurrentUser();
      _currentUser = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    notifyListeners();
  }
}
