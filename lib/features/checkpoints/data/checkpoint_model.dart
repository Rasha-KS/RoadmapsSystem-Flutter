import 'package:roadmaps/features/checkpoints/domain/checkpoint_entity.dart';
import 'package:roadmaps/features/checkpoints/domain/option_entity.dart';
import 'package:roadmaps/features/checkpoints/domain/question_entity.dart';

class CheckpointModel {
  final String id;
  final String title;
  final String? subtitle;
  final List<QuestionModel> questions;

  const CheckpointModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.questions,
  });

  factory CheckpointModel.fromJson(Map<String, dynamic> json) {
    return CheckpointModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      questions: (json['questions'] as List<dynamic>)
          .map((item) => QuestionModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  CheckpointEntity toEntity() {
    return CheckpointEntity(
      id: id,
      title: title,
   
      questions: questions
          .map((question) => question.toEntity())
          .toList(growable: false),
    );
  }
}

class QuestionModel {
  final String id;
  final String text;
  final List<OptionModel> options;
  final String correctOptionId;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionId,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>)
          .map((item) => OptionModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
      correctOptionId: json['correct_option_id'] as String,
    );
  }

  QuestionEntity toEntity() {
    return QuestionEntity(
      id: id,
      text: text,
      options: options
          .map((option) => option.toEntity())
          .toList(growable: false),
      correctOptionId: correctOptionId,
    );
  }
}

class OptionModel {
  final String id;
  final String text;

  const OptionModel({required this.id, required this.text});

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(id: json['id'] as String, text: json['text'] as String);
  }

  OptionEntity toEntity() {
    return OptionEntity(id: id, text: text);
  }
}
