import 'package:roadmaps/features/lessons/domain/lesson_entity.dart';
import 'package:roadmaps/features/lessons/domain/resource_entity.dart';
import 'package:roadmaps/features/lessons/domain/sub_lesson_entity.dart';

class LessonModel {
  final int id;
  final int learningUnitId;
  final String title;
  final String description;
  final int position;
  final bool isActive;
  final int subLessonsCount;

  const LessonModel({
    required this.id,
    required this.learningUnitId,
    required this.title,
    required this.description,
    required this.position,
    required this.isActive,
    required this.subLessonsCount,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: _asInt(json['id']),
      learningUnitId: _asInt(json['learning_unit_id']),
      title: _asString(json['title']),
      description: _asString(json['description']),
      position: _asInt(json['position']),
      isActive: _asBool(json['is_active'], fallback: true),
      subLessonsCount: _asInt(json['sub_lessons_count']),
    );
  }

  LessonEntity toEntity({
    List<SubLessonEntity> subLessons = const [],
  }) {
    return LessonEntity(
      id: id,
      title: title,
      description: description,
      subLessons: subLessons,
    );
  }
}

class SubLessonModel {
  final int id;
  final int lessonId;
  final String title;
  final int position;
  final String? description;
  final List<ResourceEntity> resources;

  const SubLessonModel({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.position,
    required this.description,
    required this.resources,
  });

  factory SubLessonModel.fromJson(Map<String, dynamic> json) {
    final resources = _extractResourceList(json['resources']);
    return SubLessonModel(
      id: _asInt(json['id']),
      lessonId: _asInt(json['lesson_id']),
      title: _asString(json['title'], fallback: 'الجزء'),
      position: _asInt(json['position']),
      description: _asNullableString(json['description']),
      resources: resources,
    );
  }

  SubLessonEntity toEntity() {
    return SubLessonEntity(
      id: id,
      lessonId: lessonId,
      title: title,
      position: position,
      description: description,
      resourcesCount: resources.length,
      resources: resources,
    );
  }
}

class ResourceModel {
  final int id;
  final String title;
  final String type;
  final String language;
  final String link;

  const ResourceModel({
    required this.id,
    required this.title,
    required this.type,
    required this.language,
    required this.link,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: _asInt(json['id']),
      title: _asString(json['title']),
      type: _asString(json['type']),
      language: _asString(json['language']),
      link: _asString(json['link']),
    );
  }

  ResourceEntity toEntity() {
    return ResourceEntity(
      id: id,
      title: title,
      type: _mapType(type),
      language: language,
      link: link,
    );
  }

  static ResourceType _mapType(String value) {
    switch (value) {
      case 'article':
        return ResourceType.article;
      case 'video':
        return ResourceType.video;
      case 'book':
        return ResourceType.book;
      default:
        return ResourceType.other;
    }
  }
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

List<ResourceEntity> _extractResourceList(dynamic value) {
  if (value is! List) {
    return <ResourceEntity>[];
  }

  return value
      .whereType<Map<String, dynamic>>()
      .map(ResourceModel.fromJson)
      .map((item) => item.toEntity())
      .toList(growable: false);
}
