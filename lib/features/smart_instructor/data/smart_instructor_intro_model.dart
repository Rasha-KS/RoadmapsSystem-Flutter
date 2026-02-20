import 'package:roadmaps/features/smart_instructor/domain/smart_instructor_intro_entity.dart';

class SmartInstructorIntroModel extends SmartInstructorIntroEntity {
  const SmartInstructorIntroModel({
    required super.title,
    required super.subtitle,
    required super.ctaLabel,
  });

  factory SmartInstructorIntroModel.fromJson(Map<String, dynamic> json) {
    return SmartInstructorIntroModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      ctaLabel: json['cta_label'] as String,
    );
  }
}
