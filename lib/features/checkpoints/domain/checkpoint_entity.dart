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
}
