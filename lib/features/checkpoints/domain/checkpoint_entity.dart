import 'package:roadmaps/features/checkpoints/domain/question_entity.dart';

class CheckpointEntity {
  final String id;
  final int quizId;
  final int learningUnitId;
  final String title;
  final String subtitle;
  final bool answersRevealed;
  final int minXp;
  final int maxXp;
  final List<QuestionEntity> questions;

  const CheckpointEntity({
    required this.id,
    required this.quizId,
    required this.learningUnitId,
    required this.title,
    required this.subtitle,
    required this.answersRevealed,
    required this.minXp,
    required this.maxXp,
    required this.questions,
  });

  CheckpointEntity copyWith({
    String? id,
    int? quizId,
    int? learningUnitId,
    String? title,
    String? subtitle,
    bool? answersRevealed,
    int? minXp,
    int? maxXp,
    List<QuestionEntity>? questions,
  }) {
    return CheckpointEntity(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      learningUnitId: learningUnitId ?? this.learningUnitId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      answersRevealed: answersRevealed ?? this.answersRevealed,
      minXp: minXp ?? this.minXp,
      maxXp: maxXp ?? this.maxXp,
      questions: questions ?? this.questions,
    );
  }
}
