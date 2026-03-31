import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import 'package:roadmaps/features/challenge/domain/challenge_entity.dart';
import 'package:roadmaps/features/challenge/domain/get_challenge_by_learning_unit_usecase.dart';
import 'package:roadmaps/features/challenge/domain/run_challenge_code_usecase.dart';

enum ChallengeScreenState { initial, loading, loaded, error }

enum ChallengeRunState { idle, running, success, failure }

class ChallengeProvider extends SafeChangeNotifier {
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
  String? _errorMessage;
  bool _isDescriptionExpanded = false;
  ChallengeScreenState _state = ChallengeScreenState.initial;
  ChallengeRunState _runState = ChallengeRunState.idle;

  ChallengeEntity? get challenge => _challenge;
  ChallengeRunResultEntity? get lastRunResult => _lastRunResult;
  String get userCode => _userCode;
  String? get errorMessage => _errorMessage;
  bool get isDescriptionExpanded => _isDescriptionExpanded;
  ChallengeScreenState get state => _state;
  ChallengeRunState get runState => _runState;
  bool get canFinish =>
      _challenge != null &&
      _state == ChallengeScreenState.loaded &&
      _runState != ChallengeRunState.running;

  Future<ChallengeEntity?> getChallengeById(
    int challengeId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache.containsKey(challengeId)) {
      return _cache[challengeId];
    }

    final challenge = await _getChallengeByLearningUnitUseCase(challengeId);
    if (challenge != null) {
      _cache[challengeId] = challenge;
    }
    return challenge;
  }

  Future<void> loadChallenge(
    int challengeId, {
    bool forceRefresh = false,
    bool keepLocalData = false,
  }) async {
    final currentChallengeId = _challenge?.id;
    _state = ChallengeScreenState.loading;
    _runState = ChallengeRunState.idle;
    _lastRunResult = null;
    _errorMessage = null;
    if (!keepLocalData) {
      _challenge = null;
    }
    notifyListeners();

    try {
      final fetched = await getChallengeById(
        challengeId,
        forceRefresh: forceRefresh,
      );
      if (fetched == null) {
        _state = ChallengeScreenState.error;
        _errorMessage = 'تعذر تحميل بيانات التحدي.';
      } else {
        _challenge = fetched;
        final shouldKeepCurrentCode =
            keepLocalData &&
            currentChallengeId == fetched.id &&
            _userCode.trim().isNotEmpty;
        _userCode = shouldKeepCurrentCode ? _userCode : fetched.starterCode;
        _state = ChallengeScreenState.loaded;
      }
    } catch (error) {
      _state = ChallengeScreenState.error;
      _errorMessage = _friendlyError(error);
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

  Future<void> runCode({required int challengeId}) async {
    await _submitCode(challengeId: challengeId);
  }

  Future<bool> finishChallenge({required int challengeId}) async {
    final result = await _submitCode(challengeId: challengeId);
    return result?.passed ?? false;
  }

  Future<ChallengeRunResultEntity?> _submitCode({
    required int challengeId,
  }) async {
    if (_userCode.trim().isEmpty) {
      _runState = ChallengeRunState.failure;
      _lastRunResult = const ChallengeRunResultEntity(
        attemptId: null,
        passed: false,
        executionOutput: 'الكود فارغ.',
        details: <ChallengeExecutionDetailEntity>[],
      );
      notifyListeners();
      return _lastRunResult;
    }

    _runState = ChallengeRunState.running;
    _lastRunResult = null;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _runChallengeCodeUseCase(
        challengeId: challengeId,
        userCode: _userCode,
      );
      _lastRunResult = result;
      _runState = result.passed
          ? ChallengeRunState.success
          : ChallengeRunState.failure;
      return result;
    } catch (error) {
      final message = _friendlyError(error);
      _errorMessage = message;
      _runState = ChallengeRunState.failure;
      _lastRunResult = ChallengeRunResultEntity(
        attemptId: null,
        passed: false,
        executionOutput: message,
        details: const <ChallengeExecutionDetailEntity>[],
      );
      return null;
    } finally {
      notifyListeners();
    }
  }

  String _friendlyError(Object error) {
    if (error is TimeoutApiException) {
      return 'استغرق تنفيذ التحدي وقتًا أطول من المعتاد. حاول مرة أخرى.';
    }
    if (error is NetworkException) {
      return 'تعذر الاتصال حاليًا. تحقق من الشبكة وحاول مرة أخرى.';
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'حدث خطأ أثناء تنفيذ التحدي. حاول مرة أخرى.';
  }
}
