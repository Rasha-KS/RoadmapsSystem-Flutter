import 'package:roadmaps/features/checkpoints/domain/option_entity.dart';

class QuestionEntity {
  final String id;
  final String text;
  final List<OptionEntity> options;
  final String correctOptionId;

  const QuestionEntity({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionId,
  });
}
