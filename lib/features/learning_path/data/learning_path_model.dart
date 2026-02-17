import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';


class LearningUnitModel {
  final int id;
  final int roadmapId;
  final String title;
  final int position;

  /// يحدد نوع الوحدة: lesson / quiz / challenge
  final String type;

  /// XP المطلوب (خاص بالتحدي)
  final int? minXp;

  LearningUnitModel({
    required this.id,
    required this.roadmapId,
    required this.title,
    required this.position,
    required this.type,
    this.minXp,
  });

  /// 🔹 عند جاهزية API
  factory LearningUnitModel.fromJson(Map<String, dynamic> json) {
    return LearningUnitModel(
      id: json['id'],
      roadmapId: json['roadmap_id'],
      title: json['title'],
      position: json['position'],
      type: json['type'], 
      minXp: json['min_xp'],
    );
  }

  /// 🔹 تحويل إلى Entity (هنا يتم ربطه بالـ Domain)
  LearningUnitEntity toEntity() {
    return LearningUnitEntity(
      id: id,
      roadmapId: roadmapId,
      title: title,
      position: position,
      type: _mapType(type),
      status: LearningUnitStatus.locked,
      requiredXp: minXp ?? 0,
    );
  }

  LearningUnitType _mapType(String type) {
    switch (type) {
      case 'lesson':
        return LearningUnitType.lesson;
      case 'quiz':
        return LearningUnitType.quiz;
      case 'challenge':
        return LearningUnitType.challenge;
      default:
        return LearningUnitType.lesson;
    }
  }
}
