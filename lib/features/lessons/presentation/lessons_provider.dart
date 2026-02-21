import 'package:flutter/material.dart';
import 'package:roadmaps/features/lessons/domain/get_lesson_usecase.dart';
import 'package:roadmaps/features/lessons/domain/lesson_entity.dart';

class LessonsProvider extends ChangeNotifier {
  final GetLessonUseCase _getLessonUseCase;

  LessonsProvider(this._getLessonUseCase);

  LessonEntity? lesson;
  bool isLoading = false;

  Future<void> fetchLesson(String learningUnitId) async {
    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 250));
      lesson = await _getLessonUseCase(learningUnitId);
    } catch (_) {
      lesson = null;
    }

    isLoading = false;
    notifyListeners();
  }
}
