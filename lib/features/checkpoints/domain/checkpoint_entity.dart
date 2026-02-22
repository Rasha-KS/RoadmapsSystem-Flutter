import 'package:roadmaps/features/checkpoints/domain/question_entity.dart';

class CheckpointEntity {
  final String id;
  final String title;
  
  final List<QuestionEntity> questions;

  const CheckpointEntity({
    required this.id,
    required this.title,
  
    required this.questions,
  });
}
