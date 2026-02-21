import 'package:flutter/material.dart';
import 'package:roadmaps/features/challenge/domain/challenge_entity.dart';
import 'package:roadmaps/features/challenge/domain/get_challenge_by_learning_unit_usecase.dart';
import 'package:roadmaps/features/challenge/domain/run_challenge_code_usecase.dart';

enum ChallengeScreenState { initial, loading, loaded, error }

enum ChallengeRunState { idle, running, success, failure }

class ChallengeProvider extends ChangeNotifier {
  final GetChallengeByLearningUnitUseCase _getChallengeByLearningUnitUseCase;
  final RunChallengeCodeUseCase _runChallengeCodeUseCase;

  ChallengeProvider({
    required GetChallengeByLearningUnitUseCase
    getChallengeByLearningUnitUseCase,
    required RunChallengeCodeUseCase runChallengeCodeUseCase,
  }) : _getChallengeByLearningUnitUseCase = getChallengeByLearningUnitUseCase,
       _runChallengeCodeUseCase = runChallengeCodeUseCase;

  final Map<int, ChallengeEntity> _cache = <int, ChallengeEntity>{};

  ChallengeEntity? _challenge;
  ChallengeRunResultEntity? _lastRunResult;
  String _userCode = '';
  bool _isDescriptionExpanded = false;
  ChallengeScreenState _state = ChallengeScreenState.initial;
  ChallengeRunState _runState = ChallengeRunState.idle;

  ChallengeEntity? get challenge => _challenge;
  ChallengeRunResultEntity? get lastRunResult => _lastRunResult;
  String get userCode => _userCode;
  bool get isDescriptionExpanded => _isDescriptionExpanded;
  ChallengeScreenState get state => _state;
  ChallengeRunState get runState => _runState;
  bool get canFinish => _runState == ChallengeRunState.success;

  Future<ChallengeEntity?> getChallengeByLearningUnitId(
    int learningUnitId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache.containsKey(learningUnitId)) {
      return _cache[learningUnitId];
    }

    final challenge = await _getChallengeByLearningUnitUseCase(learningUnitId);
    if (challenge != null) {
      _cache[learningUnitId] = challenge;
    }
    return challenge;
  }

  Future<void> loadChallenge(
    int learningUnitId, {
    bool forceRefresh = false,
    bool keepLocalData = false,
  }) async {
    _state = ChallengeScreenState.loading;
    _runState = ChallengeRunState.idle;
    _lastRunResult = null;
    if (!keepLocalData) {
      _challenge = null;
    }
    notifyListeners();

    try {
      final fetched = await getChallengeByLearningUnitId(
        learningUnitId,
        forceRefresh: forceRefresh,
      );
      if (fetched == null) {
        _state = ChallengeScreenState.error;
      } else {
        _challenge = fetched;
        _userCode = fetched.starterCode;
        _state = ChallengeScreenState.loaded;
      }
    } catch (_) {
      _state = ChallengeScreenState.error;
    }

    notifyListeners();
  }

  void updateUserCode(String code) {
    _userCode = code;
    if (_runState == ChallengeRunState.success ||
        _runState == ChallengeRunState.failure) {
      _runState = ChallengeRunState.idle;
      _lastRunResult = null;
    }
    notifyListeners();
  }

  void toggleDescription() {
    _isDescriptionExpanded = !_isDescriptionExpanded;
    notifyListeners();
  }

  Future<void> runCode({required int challengeId, required int userId}) async {
    if (_userCode.trim().isEmpty) {
      _runState = ChallengeRunState.failure;
      _lastRunResult = const ChallengeRunResultEntity(
        passed: false,
        executionOutput: 'الكود فارغ',
      );
      notifyListeners();
      return;
    }

    _runState = ChallengeRunState.running;
    _lastRunResult = null;
    notifyListeners();

    try {
      final result = await _runChallengeCodeUseCase(
        challengeId: challengeId,
        userId: userId,
        userCode: _userCode,
      );
      _lastRunResult = result;
      _runState = result.passed
          ? ChallengeRunState.success
          : ChallengeRunState.failure;
    } catch (_) {
      _runState = ChallengeRunState.failure;
      _lastRunResult = const ChallengeRunResultEntity(
        passed: false,
        executionOutput: 'حدث خطأ أثناء التنفيذ',
      );
    }

    notifyListeners();
  }
}
