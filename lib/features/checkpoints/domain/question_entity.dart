import 'package:roadmaps/features/checkpoints/domain/option_entity.dart';

class QuestionEntity {
  final String id;
  final String text;
  final List<OptionEntity> options;
  final String correctOptionId;
  final int questionXp;

  const QuestionEntity({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionId,
    this.questionXp = 0,
  });

  QuestionEntity copyWith({
    String? id,
    String? text,
    List<OptionEntity>? options,
    String? correctOptionId,
    int? questionXp,
  }) {
    return QuestionEntity(
      id: id ?? this.id,
      text: text ?? this.text,
      options: options ?? this.options,
      correctOptionId: correctOptionId ?? this.correctOptionId,
      questionXp: questionXp ?? this.questionXp,
    );
  }
}
