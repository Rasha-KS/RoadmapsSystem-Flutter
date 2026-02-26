import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';

class LearningUnitModel {
  final int id;
  final int roadmapId;
  final String title;
  final int position;
  final String type;
  final String status;
  final int? minXp;

  LearningUnitModel({
    required this.id,
    required this.roadmapId,
    required this.title,
    required this.position,
    required this.type,
    required this.status,
    this.minXp,
  });

  factory LearningUnitModel.fromJson(Map<String, dynamic> json) {
    return LearningUnitModel(
      id: json['id'],
      roadmapId: json['roadmap_id'],
      title: json['title'],
      position: json['position'],
      type: json['type'],
      status: json['status'] ?? 'locked',
      minXp: json['min_xp'],
    );
  }

  factory LearningUnitModel.fromEntity(LearningUnitEntity entity) {
    return LearningUnitModel(
      id: entity.id,
      roadmapId: entity.roadmapId,
      title: entity.title,
      position: entity.position,
      type: _mapTypeToString(entity.type),
      status: _mapStatusToString(entity.status),
      minXp: entity.requiredXp,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'roadmap_id': roadmapId,
      'title': title,
      'position': position,
      'type': type,
      'status': status,
      'min_xp': minXp ?? 0,
    };
  }

  LearningUnitEntity toEntity() {
    return LearningUnitEntity(
      id: id,
      roadmapId: roadmapId,
      title: title,
      position: position,
      type: _mapType(type),
      status: _mapStatus(status),
      requiredXp: minXp ?? 0,
    );
  }

  static LearningUnitType _mapType(String type) {
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

  static LearningUnitStatus _mapStatus(String status) {
    switch (status) {
      case 'completed':
        return LearningUnitStatus.completed;
      case 'unlocked':
        return LearningUnitStatus.unlocked;
      case 'locked':
      default:
        return LearningUnitStatus.locked;
    }
  }

  static String _mapTypeToString(LearningUnitType type) {
    switch (type) {
      case LearningUnitType.lesson:
        return 'lesson';
      case LearningUnitType.quiz:
        return 'quiz';
      case LearningUnitType.challenge:
        return 'challenge';
    }
  }

  static String _mapStatusToString(LearningUnitStatus status) {
    switch (status) {
      case LearningUnitStatus.completed:
        return 'completed';
      case LearningUnitStatus.unlocked:
        return 'unlocked';
      case LearningUnitStatus.locked:
        return 'locked';
    }
  }
}
