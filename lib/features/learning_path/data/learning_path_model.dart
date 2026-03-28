import 'package:roadmaps/features/learning_path/domain/learning_path_entity.dart';
import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';
import 'package:roadmaps/features/roadmaps/domain/roadmap_entity.dart';

class LearningPathModel {
  final int roadmapId;
  final RoadmapModel roadmap;
  final List<LearningUnitModel> units;

  LearningPathModel({
    required this.roadmapId,
    required this.roadmap,
    required this.units,
  });

  factory LearningPathModel.fromJson(Map<String, dynamic> json) {
    final roadmap = RoadmapModel.fromJson(
      _asMap(json['roadmap']),
    );
    final units = _extractList(json['units'])
      ..sort((left, right) => left.position.compareTo(right.position));
    return LearningPathModel(
      roadmapId: roadmap.id,
      roadmap: roadmap,
      units: units,
    );
  }

  LearningPathEntity toEntity() {
    return LearningPathEntity(
      roadmap: roadmap.toEntity(),
      units: units
          .map((unit) => unit.toEntity(roadmapId: roadmapId))
          .toList(growable: false),
    );
  }
}

class RoadmapModel {
  final int id;
  final String title;
  final String description;
  final String level;

  RoadmapModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    return RoadmapModel(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      level: _asString(json['level']),
    );
  }

  RoadmapEntity toEntity() {
    return RoadmapEntity(
      id: id,
      title: title,
      level: level,
      description: description,
      status: 'active',
      isActive: true,
      isEnrolled: true,
    );
  }
}

class LearningUnitModel {
  final int id;
  final int position;
  final String unitType;
  final String label;
  final int entityId;
  final String entityType;
  final String entityTitle;
  final String? entityDescription;
  final int entityPosition;
  final bool entityIsActive;
  final bool isLocked;
  final bool isCompleted;
  final bool trackingExists;
  final bool trackingIsComplete;
  final DateTime? trackingLastUpdatedAt;
  final int entityRequiredXp;

  LearningUnitModel({
    required this.id,
    required this.position,
    required this.unitType,
    required this.label,
    required this.entityId,
    required this.entityType,
    required this.entityTitle,
    required this.entityDescription,
    required this.entityPosition,
    required this.entityIsActive,
    required this.entityRequiredXp,
    required this.isLocked,
    required this.isCompleted,
    required this.trackingExists,
    required this.trackingIsComplete,
    required this.trackingLastUpdatedAt,
  });

  factory LearningUnitModel.fromJson(Map<String, dynamic> json) {
    final entity = _asMap(json['entity']);
    final tracking = _asMap(json['tracking']);

    return LearningUnitModel(
      id: _asInt(json['id']),
      position: _asInt(json['position']),
      unitType: _asString(json['unit_type']),
      label: _asString(json['label']),
      entityId: _asInt(entity['id']),
      entityType: _asString(entity['type']),
      entityTitle: _asString(entity['title']),
      entityDescription: _asNullableString(entity['description']),
      entityPosition: _asInt(entity['position']),
      entityIsActive: _asBool(entity['is_active'], fallback: true),
      entityRequiredXp: _asInt(
        entity['min_xp'] ?? entity['required_xp'] ?? json['min_xp'] ?? json['required_xp'],
      ),
      isLocked: _asBool(json['is_locked']),
      isCompleted: _asBool(json['is_completed']),
      trackingExists: _asBool(tracking['exists']),
      trackingIsComplete: _asBool(tracking['is_complete']),
      trackingLastUpdatedAt: _parseDateTime(tracking['last_updated_at']),
    );
  }

  LearningUnitEntity toEntity({required int roadmapId}) {
    final type = _mapType(unitType);
    final status = isCompleted
        ? LearningUnitStatus.completed
        : isLocked
            ? LearningUnitStatus.locked
            : LearningUnitStatus.unlocked;

    return LearningUnitEntity(
      id: id,
      roadmapId: roadmapId,
      title: entityTitle.isNotEmpty ? entityTitle : label,
      label: label,
      position: position,
      type: type,
      status: status,
      entityId: entityId,
      description: entityDescription,
      isLocked: isLocked,
      isCompleted: isCompleted,
      isActive: entityIsActive,
      trackingExists: trackingExists,
      trackingIsComplete: trackingIsComplete,
      trackingLastUpdatedAt: trackingLastUpdatedAt,
      requiredXp: entityRequiredXp,
    );
  }

  static LearningUnitType _mapType(String type) {
    switch (type) {
      case 'quiz':
        return LearningUnitType.quiz;
      case 'challenge':
        return LearningUnitType.challenge;
      case 'lesson':
      default:
        return LearningUnitType.lesson;
    }
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  return <String, dynamic>{};
}

List<LearningUnitModel> _extractList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map<String, dynamic>>()
        .map(LearningUnitModel.fromJson)
        .toList(growable: false);
  }
  return <LearningUnitModel>[];
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

String _asString(dynamic value, {String fallback = ''}) {
  final text = value?.toString().trim();
  if (text != null && text.isNotEmpty) return text;
  return fallback;
}

String? _asNullableString(dynamic value) {
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return text;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  final normalized = value?.toString().trim().toLowerCase();
  switch (normalized) {
    case '1':
    case 'true':
    case 'yes':
      return true;
    case '0':
    case 'false':
    case 'no':
      return false;
    default:
      return fallback;
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  final text = value?.toString().trim();
  if (text == null || text.isEmpty) return null;
  return DateTime.tryParse(text);
}
