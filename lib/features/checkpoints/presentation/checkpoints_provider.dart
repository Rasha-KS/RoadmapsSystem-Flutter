import 'dart:async';

import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import 'package:roadmaps/features/checkpoints/data/checkpoint_repository.dart';
import 'package:roadmaps/features/checkpoints/domain/checkpoint_entity.dart';
import 'package:roadmaps/features/checkpoints/domain/checkpoint_submission_result.dart';
import 'package:roadmaps/features/checkpoints/domain/create_checkpoint_attempt_usecase.dart';
import 'package:roadmaps/features/checkpoints/domain/get_checkpoint_attempts_count_usecase.dart';
import 'package:roadmaps/features/checkpoints/domain/get_checkpoint_usecase.dart';
import 'package:roadmaps/features/checkpoints/domain/retake_checkpoint_attempt_usecase.dart';
import 'package:roadmaps/features/checkpoints/domain/submit_checkpoint_attempt_usecase.dart';
import 'package:roadmaps/features/checkpoints/domain/question_entity.dart';

class CheckpointsProvider extends SafeChangeNotifier {
  final GetCheckpointUseCase _getCheckpointUseCase;
  final CreateCheckpointAttemptUseCase _createAttemptUseCase;
  final GetCheckpointAttemptsCountUseCase _getAttemptsCountUseCase;
  final RetakeCheckpointAttemptUseCase _retakeAttemptUseCase;
  final SubmitCheckpointAttemptUseCase _submitAttemptUseCase;

  CheckpointsProvider({
    required GetCheckpointUseCase getCheckpointUseCase,
    required CreateCheckpointAttemptUseCase createAttemptUseCase,
    required GetCheckpointAttemptsCountUseCase getAttemptsCountUseCase,
    required RetakeCheckpointAttemptUseCase retakeAttemptUseCase,
    required SubmitCheckpointAttemptUseCase submitAttemptUseCase,
  })  : _getCheckpointUseCase = getCheckpointUseCase,
        _createAttemptUseCase = createAttemptUseCase,
        _getAttemptsCountUseCase = getAttemptsCountUseCase,
        _retakeAttemptUseCase = retakeAttemptUseCase,
        _submitAttemptUseCase = submitAttemptUseCase;

  CheckpointEntity? checkpoint;
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;
  int? attemptId;
  int? _currentQuizId;
  String? _currentLearningPathId;
  bool _attemptReady = false;
  bool _useRetakeAttempt = false;
  CheckpointSubmissionResult? lastSubmissionResult;
  final Map<String, String> selectedOptionByQuestionId = <String, String>{};

  bool get isAllAnswered {
    final currentCheckpoint = checkpoint;
    if (currentCheckpoint == null || currentCheckpoint.questions.isEmpty) {
      return false;
    }
    return currentCheckpoint.questions.every(
      (question) => selectedOptionByQuestionId.containsKey(question.id),
    );
  }

  int? get correctCount {
    final currentCheckpoint = checkpoint;
    if (currentCheckpoint == null) return null;
    if (!_hasAnswerKey(currentCheckpoint)) return null;
    return _countCorrectAnswers(currentCheckpoint, selectedOptionByQuestionId);
  }

  int get totalQuestions => checkpoint?.questions.length ?? 0;

  int get maximumPossibleXp {
    final currentCheckpoint = checkpoint;
    if (currentCheckpoint == null) return 0;
    if (currentCheckpoint.maxXp > 0) {
      return currentCheckpoint.maxXp;
    }
    final total = currentCheckpoint.questions.fold<int>(
      0,
      (sum, question) => sum + (question.questionXp > 0 ? question.questionXp : 0),
    );
    if (total > 0) {
      return total;
    }
    return currentCheckpoint.questions.length * _defaultQuestionXp;
  }

  int get minimumRequiredXp {
    final currentCheckpoint = checkpoint;
    if (currentCheckpoint == null) return 0;
    if (currentCheckpoint.minXp > 0) {
      return currentCheckpoint.minXp;
    }
    final totalPossibleXp = maximumPossibleXp;
    return (totalPossibleXp * _passingPercentThreshold / 100).ceil();
  }

  int get previewEarnedXp {
    final currentCheckpoint = checkpoint;
    final correct = correctCount;
    if (currentCheckpoint == null || correct == null) return 0;
    return _earnedXpFromSelectedAnswers(
      currentCheckpoint,
      selectedOptionByQuestionId,
    );
  }

  double get previewScorePercent {
    final total = maximumPossibleXp;
    if (total <= 0) return 0;
    return (previewEarnedXp / total) * 100;
  }

  Future<int> getAttemptsCount({required int quizId}) {
    return _getAttemptsCountUseCase(quizId: quizId);
  }

  Future<void> fetchCheckpoint({
    required String learningPathId,
    required String checkpointId,
    bool useRetakeAttempt = false,
    bool resetState = true,
  }) async {
    final quizId = int.tryParse(checkpointId) ?? 0;
    if (quizId <= 0) {
      errorMessage = 'معرف الاختبار غير صالح.';
      notifyListeners();
      return;
    }

    if (resetState || _currentQuizId != quizId) {
      _resetQuizState();
    }

    _currentQuizId = quizId;
    _currentLearningPathId = learningPathId;
    _useRetakeAttempt = useRetakeAttempt;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      checkpoint = await _getCheckpointUseCase(
        learningPathId: learningPathId,
        checkpointId: checkpointId,
      );
    } catch (error) {
      errorMessage = _friendlyError(error);
      checkpoint = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> retryCurrentCheckpoint({required String learningPathId}) async {
    final quizId = _currentQuizId;
    if (quizId == null || quizId <= 0) return;

    await _loadCheckpointDetails(
      learningPathId: learningPathId,
      checkpointId: quizId.toString(),
    );
  }

  Future<void> retakeCurrentCheckpoint({
    required String learningPathId,
  }) async {
    final quizId = _currentQuizId;
    if (quizId == null || quizId <= 0) return;

    lastSubmissionResult = null;
    selectedOptionByQuestionId.clear();
    errorMessage = null;

    if (!_attemptReady || attemptId == null) {
      notifyListeners();
      return;
    }

    _attemptReady = false;
    attemptId = null;
    checkpoint = null;
    isLoading = true;
    notifyListeners();

    try {
      attemptId = _useRetakeAttempt
          ? await _retakeAttemptUseCase(quizId: quizId)
          : await _createAttemptUseCase(quizId: quizId);
      _attemptReady = true;
      checkpoint = await _getCheckpointUseCase(
        learningPathId: learningPathId,
        checkpointId: quizId.toString(),
      );
    } catch (error) {
      errorMessage = _friendlyError(error);
      checkpoint = null;
    }

    isLoading = false;
    notifyListeners();
  }

  void selectOption({required String questionId, required String optionId}) {
    selectedOptionByQuestionId[questionId] = optionId;
    notifyListeners();
  }

  void resetAnswers() {
    selectedOptionByQuestionId.clear();
    notifyListeners();
  }

  Future<CheckpointSubmissionResult?> submitAnswers() async {
    final currentCheckpoint = checkpoint;
    if (currentCheckpoint == null) {
      errorMessage = 'تعذر إرسال إجابات الاختبار.';
      notifyListeners();
      return null;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final quizId = _currentQuizId ?? currentCheckpoint.quizId;
      attemptId = null;
      _attemptReady = false;
      await _ensureAttemptCreated(
        quizId: quizId,
        useRetakeAttempt: _useRetakeAttempt,
      );
      final learningPathId = _currentLearningPathId;
      if (learningPathId != null && learningPathId.isNotEmpty) {
        checkpoint = await _refreshCheckpointForSubmission(
          learningPathId: learningPathId,
          checkpointId: quizId.toString(),
        );
      }
    } catch (error) {
      errorMessage = _friendlyError(error);
      isSubmitting = false;
      notifyListeners();
      return null;
    }

    try {
      final currentAttemptId = attemptId;
      if (currentAttemptId == null) {
        throw const ApiException('فشل إرسال النتيجة حاول مرة أخرى');
      }
      final submittedAnswers = Map<String, String>.from(selectedOptionByQuestionId);
      final submissionCheckpoint = checkpoint ?? currentCheckpoint;
      final earnedXp = _earnedXpFromSelectedAnswers(
        submissionCheckpoint,
        submittedAnswers,
      );
      final minimumXp = minimumRequiredXp;
      final passed = earnedXp >= minimumXp;
      final submission = await _submitAttemptUseCase(
        attemptId: currentAttemptId,
        answers: submittedAnswers,
        score: earnedXp,
        passed: passed,
      );
      final result = _buildSubmissionResult(
        checkpoint: submissionCheckpoint,
        submission: submission,
        answers: submittedAnswers,
      );
      lastSubmissionResult = result;
      return result;
    } catch (error) {
      errorMessage = 'فشل إرسال النتيجة حاول مرة أخرى';
      return null;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _ensureAttemptCreated({
    required int quizId,
    required bool useRetakeAttempt,
  }) async {
    if (_attemptReady && attemptId != null) {
      return;
    }

    attemptId = useRetakeAttempt
        ? await _retakeAttemptUseCase(quizId: quizId)
        : await _createAttemptUseCase(quizId: quizId);
    _attemptReady = true;
  }

  Future<void> _loadCheckpointDetails({
    required String learningPathId,
    required String checkpointId,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      checkpoint = await _getCheckpointUseCase(
        learningPathId: learningPathId,
        checkpointId: checkpointId,
      );
    } catch (error) {
      errorMessage = _friendlyError(error);
      checkpoint = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<CheckpointEntity> _refreshCheckpointForSubmission({
    required String learningPathId,
    required String checkpointId,
  }) async {
    CheckpointEntity? refreshedCheckpoint;
    final attempts = <Duration>[
      Duration.zero,
      const Duration(milliseconds: 250),
      const Duration(milliseconds: 500),
    ];

    for (final delay in attempts) {
      if (delay != Duration.zero) {
        await Future<void>.delayed(delay);
      }

      final candidate = await _getCheckpointUseCase(
        learningPathId: learningPathId,
        checkpointId: checkpointId,
      );
      refreshedCheckpoint = candidate;
      if (_hasAnswerKey(candidate)) {
        return candidate;
      }
    }

    if (refreshedCheckpoint != null) {
      return refreshedCheckpoint;
    }

    return await _getCheckpointUseCase(
      learningPathId: learningPathId,
      checkpointId: checkpointId,
    );
  }

  CheckpointSubmissionResult _buildSubmissionResult({
    required CheckpointEntity checkpoint,
    required QuizSubmissionResultModel submission,
    required Map<String, String> answers,
  }) {
    final int effectiveEarnedXp = submission.earnedPoints > 0
        ? submission.earnedPoints
        : submission.score;
    final int effectiveTotalPossibleXp = checkpoint.maxXp > 0
        ? checkpoint.maxXp
        : maximumPossibleXp;
    final int effectiveMinimumXp = checkpoint.minXp > 0
        ? checkpoint.minXp
        : minimumRequiredXp;
    final bool effectivePassed = effectiveEarnedXp >= effectiveMinimumXp;
    final int? correct = _hasAnswerKey(checkpoint)
        ? _countCorrectAnswers(checkpoint, answers)
        : null;

    return CheckpointSubmissionResult(
      attemptId: submission.attemptId ?? attemptId,
      passed: effectivePassed,
      earnedXp: effectiveEarnedXp,
      minimumRequiredXp: effectiveMinimumXp,
      maximumPossibleXp: effectiveTotalPossibleXp,
      totalQuestions: checkpoint.questions.length,
      correctCount: correct,
      scorePercent: effectiveTotalPossibleXp <= 0
          ? 0
          : (effectiveEarnedXp / effectiveTotalPossibleXp) * 100,
    );
  }

  bool _hasAnswerKey(CheckpointEntity checkpoint) {
    if (!checkpoint.answersRevealed) {
      return false;
    }
    return checkpoint.questions.any(
      (question) => question.correctOptionId.trim().isNotEmpty,
    );
  }

  int _earnedXpFromSelectedAnswers(
    CheckpointEntity checkpoint,
    Map<String, String> answers,
  ) {
    if (!_hasAnswerKey(checkpoint)) {
      return 0;
    }

    var earned = 0;
    for (final question in checkpoint.questions) {
      if (!_isSelectedAnswerCorrect(question, answers)) {
        continue;
      }
      earned += question.questionXp > 0
          ? question.questionXp
          : checkpoint.maxXp > 0 && checkpoint.questions.isNotEmpty
              ? (checkpoint.maxXp / checkpoint.questions.length).round()
              : _defaultQuestionXp;
    }
    return earned;
  }

  int _countCorrectAnswers(
    CheckpointEntity checkpoint,
    Map<String, String> answers,
  ) {
    var score = 0;
    for (final question in checkpoint.questions) {
      if (_isSelectedAnswerCorrect(question, answers)) {
        score++;
      }
    }
    return score;
  }

  bool _isSelectedAnswerCorrect(
    QuestionEntity question,
    Map<String, String> answers,
  ) {
    final correctOptionId = question.correctOptionId.trim();
    if (correctOptionId.isEmpty) return false;

    final selected = answers[question.id];
    if (selected == null) return false;

    if (_normalizeAnswerToken(selected) == _normalizeAnswerToken(correctOptionId)) {
      return true;
    }

    for (final option in question.options) {
      final matchesCorrectRef =
          _normalizeAnswerToken(option.id) == _normalizeAnswerToken(correctOptionId) ||
          _normalizeAnswerToken(option.text) == _normalizeAnswerToken(correctOptionId);
      final matchesSelection =
          _normalizeAnswerToken(selected) == _normalizeAnswerToken(option.id) ||
          _normalizeAnswerToken(selected) == _normalizeAnswerToken(option.text);
      if (matchesCorrectRef && matchesSelection) {
        return true;
      }
    }
    return false;
  }

  String _normalizeAnswerToken(String value) {
    return value.trim().toLowerCase();
  }

  void _resetQuizState() {
    checkpoint = null;
    errorMessage = null;
    isLoading = false;
    isSubmitting = false;
    attemptId = null;
    _attemptReady = false;
    _currentQuizId = null;
    _currentLearningPathId = null;
    _useRetakeAttempt = false;
    lastSubmissionResult = null;
    selectedOptionByQuestionId.clear();
  }

  String _friendlyError(Object error) {
    if (error is TimeoutApiException) {
      return 'استغرق تحميل الاختبار وقتًا أطول من المعتاد. حاول مرة أخرى.';
    }
    if (error is NetworkException) {
      return 'تعذر الاتصال حاليًا. تحقق من الشبكة وحاول مرة أخرى.';
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'تعذر تحميل الاختبار. حاول مرة أخرى.';
  }

  static const int _defaultQuestionXp = 0;
  static const double _passingPercentThreshold = 70.0;
}
