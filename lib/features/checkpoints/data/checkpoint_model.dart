import 'package:roadmaps/features/checkpoints/domain/checkpoint_entity.dart';
import 'package:roadmaps/features/checkpoints/domain/option_entity.dart';
import 'package:roadmaps/features/checkpoints/domain/question_entity.dart';

class CheckpointModel {
  final String id;
  final int quizId;
  final int learningUnitId;
  final String title;
  final String subtitle;
  final bool answersRevealed;
  final int minXp;
  final int maxXp;
  final List<QuestionModel> questions;

  const CheckpointModel({
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

  factory CheckpointModel.fromJson(Map<String, dynamic> json) {
    final quiz = _asMap(json['quiz']);
    final questions = _extractQuestions(json['questions']);

    return CheckpointModel(
      id: _asString(quiz['id'] ?? json['id']),
      quizId: _asInt(quiz['id'] ?? json['quiz_id'] ?? json['id']),
      learningUnitId: _asInt(quiz['learning_unit_id'] ?? json['learning_unit_id']),
      title: _asString(quiz['title'] ?? json['title'], fallback: 'الاختبار'),
      subtitle: _asString(
        json['subtitle'] ?? quiz['subtitle'],
        fallback: 'أكمل الاختبار للحصول على نقاط خبرة',
      ),
      answersRevealed: _asBool(json['answers_revealed'] ?? json['answersRevealed']),
      minXp: _asInt(quiz['min_xp'] ?? json['min_xp']),
      maxXp: _asInt(quiz['max_xp'] ?? json['max_xp']),
      questions: questions,
    );
  }

  CheckpointEntity toEntity() {
    return CheckpointEntity(
      id: id,
      quizId: quizId,
      learningUnitId: learningUnitId,
      title: title,
      subtitle: subtitle,
      answersRevealed: answersRevealed,
      minXp: minXp,
      maxXp: maxXp,
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
  final int order;
  final int questionXp;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.correctOptionId,
    required this.order,
    required this.questionXp,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    final options = OptionModel._extractOptions(json['options']);
    return QuestionModel(
      id: _asString(json['id']),
      text: _asString(json['question_text'] ?? json['text']),
      options: options,
      correctOptionId: _extractCorrectOptionId(json),
      order: _asInt(json['order']),
      questionXp: _asInt(json['question_xp'] ?? json['xp']),
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
      questionXp: questionXp,
    );
  }
}

class OptionModel {
  final String id;
  final String text;

  const OptionModel({required this.id, required this.text});

  factory OptionModel.fromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return OptionModel(
        id: _asString(value['id'] ?? value['value'] ?? value['text']),
        text: _asString(value['text'] ?? value['value'] ?? value['label']),
      );
    }

    final text = _asString(value);
    return OptionModel(id: text, text: text);
  }

  OptionEntity toEntity() {
    return OptionEntity(id: id, text: text);
  }

  static List<OptionModel> _extractOptions(dynamic value) {
    if (value is List) {
      return value.map(OptionModel.fromJson).toList(growable: false);
    }

    return const <OptionModel>[];
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return <String, dynamic>{};
}

List<QuestionModel> _extractQuestions(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map(QuestionModel.fromJson)
        .toList(growable: false)
      ..sort((left, right) => left.order.compareTo(right.order));
  }
  return const <QuestionModel>[];
}

String _asString(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim();
  if (text != null && text.isNotEmpty) return text;
  return fallback;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().trim().toLowerCase();
  switch (text) {
    case '1':
    case 'true':
    case 'yes':
      return true;
    default:
      return false;
  }
}

String _extractCorrectOptionId(Map<String, dynamic> json) {
  final candidates = <dynamic>[
    json['correct_option_id'],
    json['correct_answer_id'],
    json['answer_id'],
    json['correct_answer'],
    json['correct_option'],
    json['answer'],
  ];

  for (final candidate in candidates) {
    final text = _asString(candidate);
    if (text.isNotEmpty) {
      return text;
    }
  }

  for (final nested in <dynamic>[json['correct_option'], json['answer']]) {
    final map = _asMap(nested);
    if (map.isEmpty) continue;
    final text = _asString(map['id'] ?? map['value'] ?? map['text'] ?? map['answer_id']);
    if (text.isNotEmpty) return text;
  }

  final fallbackCandidates = <dynamic>[
    json['correct_answer_text'],
    json['correct_option_text'],
  ];
  for (final candidate in fallbackCandidates) {
    final text = _asString(candidate);
    if (text.isNotEmpty) {
      return text;
    }
  }

  return '';
}
