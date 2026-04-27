import 'dart:async';
import 'dart:math';

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
  final Random _random = Random();
  List<String> _currentQuestionIds = <String>[];

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
    return _maximumPossibleXpFor(currentCheckpoint);
  }

  int get minimumRequiredXp {
    final currentCheckpoint = checkpoint;
    if (currentCheckpoint == null) return 0;
    return _minimumRequiredXpFor(currentCheckpoint);
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
      final loadedCheckpoint = await _getCheckpointUseCase(
        learningPathId: learningPathId,
        checkpointId: checkpointId,
      );
      checkpoint = _buildDisplayedCheckpoint(loadedCheckpoint);
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
      final loadedCheckpoint = await _getCheckpointUseCase(
        learningPathId: learningPathId,
        checkpointId: quizId.toString(),
      );
      checkpoint = _buildDisplayedCheckpoint(loadedCheckpoint);
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
      final loadedCheckpoint = await _getCheckpointUseCase(
        learningPathId: learningPathId,
        checkpointId: checkpointId,
      );
      checkpoint = _buildDisplayedCheckpoint(loadedCheckpoint);
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
      final preparedCandidate = _buildSubmissionCheckpoint(candidate);
      refreshedCheckpoint = preparedCandidate;
      if (_hasAnswerKey(preparedCandidate)) {
        return preparedCandidate;
      }
    }

    if (refreshedCheckpoint != null) {
      return refreshedCheckpoint;
    }

    final candidate = await _getCheckpointUseCase(
      learningPathId: learningPathId,
      checkpointId: checkpointId,
    );
    return _buildSubmissionCheckpoint(candidate);
  }

  CheckpointSubmissionResult _buildSubmissionResult({
    required CheckpointEntity checkpoint,
    required QuizSubmissionResultModel submission,
    required Map<String, String> answers,
  }) {
    final int localEarnedXp = _earnedXpFromSelectedAnswers(checkpoint, answers);
    final int effectiveEarnedXp;
    if (_hasAnswerKey(checkpoint)) {
      effectiveEarnedXp = localEarnedXp;
    } else {
      effectiveEarnedXp = submission.earnedPoints > 0
          ? submission.earnedPoints
          : submission.score;
    }
    final int effectiveTotalPossibleXp = _maximumPossibleXpFor(checkpoint);
    final int effectiveMinimumXp = _minimumRequiredXpFor(checkpoint);
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
      earned += question.questionXp > 0 ? question.questionXp : _defaultQuestionXp;
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
    _currentQuestionIds = <String>[];
    lastSubmissionResult = null;
    selectedOptionByQuestionId.clear();
  }

  CheckpointEntity _buildDisplayedCheckpoint(CheckpointEntity source) {
    if (source.questions.isEmpty) {
      _currentQuestionIds = <String>[];
      return source;
    }

    if (source.questions.length <= _questionsPerAttempt) {
      _currentQuestionIds = source.questions
          .map((question) => question.id)
          .toList(growable: false);
      return source;
    }

    final selectedQuestions = _selectAttemptQuestions(
      source.questions,
      previousQuestionIds: _currentQuestionIds,
    );
    return _buildSubsetCheckpoint(
      source,
      selectedQuestions,
      updateCurrentQuestionIds: true,
    );
  }

  CheckpointEntity _buildSubmissionCheckpoint(CheckpointEntity source) {
    if (source.questions.isEmpty ||
        source.questions.length <= _questionsPerAttempt ||
        _currentQuestionIds.isEmpty) {
      return source;
    }

    final selectedQuestions = _selectQuestionsByIds(
      source.questions,
      _currentQuestionIds,
    );
    if (selectedQuestions.isEmpty) {
      return source;
    }

    return _buildSubsetCheckpoint(
      source,
      selectedQuestions,
      updateCurrentQuestionIds: false,
    );
  }

  CheckpointEntity _buildSubsetCheckpoint(
    CheckpointEntity source,
    List<QuestionEntity> selectedQuestions, {
    required bool updateCurrentQuestionIds,
  }) {
    final normalizedQuestions = _normalizeSelectedQuestions(
      source: source,
      selectedQuestions: selectedQuestions,
    );
    final adjustedMaxXp = normalizedQuestions.fold<int>(
      0,
      (sum, question) => sum + (question.questionXp > 0 ? question.questionXp : 0),
    );
    final adjustedMinXp = _minimumRequiredXpFromTotal(
      source,
      totalPossibleXp: adjustedMaxXp,
    );
    final checkpointSubset = source.copyWith(
      minXp: adjustedMinXp,
      maxXp: adjustedMaxXp,
      questions: normalizedQuestions,
    );

    if (updateCurrentQuestionIds) {
      _currentQuestionIds = normalizedQuestions
          .map((question) => question.id)
          .toList(growable: false);
    }

    return checkpointSubset;
  }

  List<QuestionEntity> _normalizeSelectedQuestions({
    required CheckpointEntity source,
    required List<QuestionEntity> selectedQuestions,
  }) {
    final fallbackQuestionXp = _fallbackQuestionXp(source);
    return selectedQuestions.map((question) {
      if (question.questionXp > 0 || fallbackQuestionXp <= 0) {
        return question;
      }
      return question.copyWith(questionXp: fallbackQuestionXp);
    }).toList(growable: false);
  }

  int _fallbackQuestionXp(CheckpointEntity _) {
    return _defaultQuestionXp;
  }

  int _maximumPossibleXpFor(CheckpointEntity checkpoint) {
    return checkpoint.questions.fold<int>(
      0,
      (sum, question) => sum + (question.questionXp > 0 ? question.questionXp : 0),
    );
  }

  int _minimumRequiredXpFor(CheckpointEntity checkpoint) {
    return _minimumRequiredXpFromTotal(
      checkpoint,
      totalPossibleXp: _maximumPossibleXpFor(checkpoint),
    );
  }

  int _minimumRequiredXpFromTotal(
    CheckpointEntity checkpoint, {
    required int totalPossibleXp,
  }) {
    if (totalPossibleXp <= 0) return 0;

    final passingPercentage = checkpoint.passingPercentage > 0
        ? checkpoint.passingPercentage
        : _passingPercentThreshold;
    final minimumXp = (totalPossibleXp * passingPercentage / 100).ceil();
    if (minimumXp > totalPossibleXp) return totalPossibleXp;
    return minimumXp;
  }

  List<QuestionEntity> _selectAttemptQuestions(
    List<QuestionEntity> questions, {
    List<String> previousQuestionIds = const <String>[],
  }) {
    if (questions.length <= _questionsPerAttempt) {
      return List<QuestionEntity>.unmodifiable(questions);
    }

    var selectedQuestions = _pickRandomQuestions(questions);
    final shouldAvoidRepeat = previousQuestionIds.length == _questionsPerAttempt;

    if (shouldAvoidRepeat &&
        _hasSameQuestionSelection(selectedQuestions, previousQuestionIds)) {
      for (var attempt = 0; attempt < _maxRandomSelectionRetries; attempt++) {
        final candidate = _pickRandomQuestions(questions);
        if (!_hasSameQuestionSelection(candidate, previousQuestionIds)) {
          selectedQuestions = candidate;
          break;
        }
      }
    }

    if (shouldAvoidRepeat &&
        _hasSameQuestionSelection(selectedQuestions, previousQuestionIds)) {
      final previousQuestionIdsSet = previousQuestionIds.toSet();
      QuestionEntity? replacementQuestion;

      for (final question in questions) {
        if (!previousQuestionIdsSet.contains(question.id)) {
          replacementQuestion = question;
          break;
        }
      }

      if (replacementQuestion != null) {
        final updatedSelection = List<QuestionEntity>.from(selectedQuestions);
        updatedSelection[updatedSelection.length - 1] = replacementQuestion;
        updatedSelection.shuffle(_random);
        selectedQuestions = updatedSelection;
      }
    }

    return List<QuestionEntity>.unmodifiable(selectedQuestions);
  }

  List<QuestionEntity> _pickRandomQuestions(List<QuestionEntity> questions) {
    final indexedQuestions = questions.asMap().entries.toList(growable: false)
      ..shuffle(_random);
    final selectedEntries = indexedQuestions.take(_questionsPerAttempt).toList();
    return selectedEntries
        .map((entry) => entry.value)
        .toList(growable: false);
  }

  bool _hasSameQuestionSelection(
    List<QuestionEntity> questions,
    List<String> questionIds,
  ) {
    if (questions.length != questionIds.length) {
      return false;
    }

    for (var index = 0; index < questions.length; index++) {
      if (questions[index].id != questionIds[index]) {
        return false;
      }
    }
    return true;
  }

  List<QuestionEntity> _selectQuestionsByIds(
    List<QuestionEntity> questions,
    List<String> questionIds,
  ) {
    final questionById = <String, QuestionEntity>{
      for (final question in questions) question.id: question,
    };
    final selectedQuestions = <QuestionEntity>[];

    for (final questionId in questionIds) {
      final question = questionById[questionId];
      if (question != null) {
        selectedQuestions.add(question);
      }
    }

    return selectedQuestions;
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
  static const int _questionsPerAttempt = 4;
  static const int _maxRandomSelectionRetries = 6;
  static const double _passingPercentThreshold = 70.0;
}
