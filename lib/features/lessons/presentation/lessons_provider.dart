import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import 'package:roadmaps/features/lessons/domain/complete_lesson_usecase.dart';
import 'package:roadmaps/features/lessons/domain/get_sub_lessons_usecase.dart';
import 'package:roadmaps/features/lessons/domain/prefetch_lesson_content_usecase.dart';
import 'package:roadmaps/features/lessons/domain/lesson_entity.dart';
import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';

class LessonsProvider extends SafeChangeNotifier {
  final GetSubLessonsUseCase _getSubLessonsUseCase;
  final CompleteLessonUseCase _completeLessonUseCase;
  final PrefetchLessonContentUseCase _prefetchLessonContentUseCase;

  LessonsProvider(
    this._getSubLessonsUseCase,
    this._completeLessonUseCase,
    this._prefetchLessonContentUseCase,
  );

  LessonEntity? lesson;
  bool isLoading = false;
  bool isCompleting = false;
  String? errorMessage;
  int? _lessonId;

  bool hasLoadedLesson(int? lessonId) {
    return lesson != null && _lessonId == lessonId;
  }

  Future<void> fetchLesson({
    required int lessonId,
    required String title,
    required String description,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final baseLesson = LessonEntity(
        id: lessonId,
        title: title.trim().isNotEmpty ? title.trim() : 'الدرس',
        description: description.trim(),
        subLessons: const [],
      );

      _lessonId = baseLesson.id;
      final subLessons = await _getSubLessonsUseCase(baseLesson.id);
      subLessons.sort(
        (left, right) => left.position.compareTo(right.position),
      );

      lesson = baseLesson.copyWith(subLessons: subLessons);
    } catch (error) {
      lesson = null;
      errorMessage = _normalizeError(error);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> completeLesson() async {
    final currentLessonId = lesson?.id ?? _lessonId;
    if (currentLessonId == null) return false;

    isCompleting = true;
    notifyListeners();

    try {
      await _completeLessonUseCase(currentLessonId);
      return true;
    } catch (error) {
      errorMessage = _normalizeError(error);
      return false;
    } finally {
      isCompleting = false;
      notifyListeners();
    }
  }

  Future<void> prefetchLearningPathLessons(
    List<LearningUnitEntity> units,
  ) async {
    await _prefetchLessonContentUseCase.call(units: units);
  }

  String _normalizeError(Object error) {
    if (error is TimeoutApiException) {
      return 'استغرق تحميل الدرس وقتًا أطول من المعتاد. حاول مرة أخرى.';
    }
    if (error is NetworkException) {
      return 'تعذر الاتصال حالياً. تحقق من الشبكة وحاول مرة أخرى.';
    }
    if (error is ApiException) {
      return error.message;
    }

    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.replaceFirst('Exception: ', '')
        : message;
  }
}
