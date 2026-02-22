import 'package:flutter/material.dart';
import 'package:roadmaps/core/constants/xp_rules.dart';
import 'package:roadmaps/features/checkpoints/domain/checkpoint_entity.dart';
import 'package:roadmaps/features/checkpoints/domain/get_checkpoint_usecase.dart';

class CheckpointsProvider extends ChangeNotifier {
  final GetCheckpointUseCase _getCheckpointUseCase;

  CheckpointsProvider(this._getCheckpointUseCase);

  static const double passingPercentThreshold =
      XpRules.checkpointPassingPercent;
  static const int xpPerCorrectAnswer = XpRules.checkpointXpPerCorrectAnswer;

  CheckpointEntity? checkpoint;
  bool isLoading = false;
  String? errorMessage;
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

  int get correctCount {
    final currentCheckpoint = checkpoint;
    if (currentCheckpoint == null) return 0;

    int score = 0;
    for (final question in currentCheckpoint.questions) {
      if (selectedOptionByQuestionId[question.id] == question.correctOptionId) {
        score++;
      }
    }
    return score;
  }

  double get scorePercent {
    final currentCheckpoint = checkpoint;
    if (currentCheckpoint == null || currentCheckpoint.questions.isEmpty) {
      return 0;
    }
    return (correctCount / currentCheckpoint.questions.length) * 100;
  }

  int get totalQuestions => checkpoint?.questions.length ?? 0;

  int get earnedXp => correctCount * xpPerCorrectAnswer;

  int get minimumRequiredXp {
    final currentCheckpoint = checkpoint;
    if (currentCheckpoint == null || currentCheckpoint.questions.isEmpty) {
      return 0;
    }
    final int totalPossibleXp =
        currentCheckpoint.questions.length * xpPerCorrectAnswer;
    return (totalPossibleXp * passingPercentThreshold / 100).ceil();
  }

  bool get isPassed => scorePercent >= passingPercentThreshold;

  Future<void> fetchCheckpoint({
    required String learningPathId,
    required String checkpointId,
  }) async {
    isLoading = true;
    errorMessage = null;
    checkpoint = null;
    selectedOptionByQuestionId.clear();
    notifyListeners();

    try {
      checkpoint = await _getCheckpointUseCase(
        learningPathId: learningPathId,
        checkpointId: checkpointId,
      );
    } catch (_) {
      errorMessage = 'تعذر تحميل الاختبار. حاول مرة أخرى.';
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
}
