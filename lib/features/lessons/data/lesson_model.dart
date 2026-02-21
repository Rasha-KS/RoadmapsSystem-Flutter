import 'package:roadmaps/features/lessons/domain/lesson_entity.dart';
import 'package:roadmaps/features/lessons/domain/resource_entity.dart';
import 'package:roadmaps/features/lessons/domain/sub_lesson_entity.dart';

class LessonModel {
  final String id;
  final String title;
  final List<SubLessonModel> subLessons;

  const LessonModel({
    required this.id,
    required this.title,
    required this.subLessons,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subLessons: (json['sub_lessons'] as List<dynamic>)
          .map((item) => SubLessonModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  LessonEntity toEntity() {
    return LessonEntity(
      id: id,
      title: title,
      subLessons: subLessons
          .map((subLesson) => subLesson.toEntity())
          .toList(growable: false),
    );
  }
}

class SubLessonModel {
  final String id;
  final String title;
  final String introductionTitle;
  final String introductionDescription;
  final List<ResourceModel> resources;

  const SubLessonModel({
    required this.id,
    required this.title,
    required this.introductionTitle,
    required this.introductionDescription,
    required this.resources,
  });

  factory SubLessonModel.fromJson(Map<String, dynamic> json) {
    return SubLessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      introductionTitle: json['introduction_title'] as String,
      introductionDescription: json['introduction_description'] as String,
      resources: (json['resources'] as List<dynamic>)
          .map((item) => ResourceModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }

  SubLessonEntity toEntity() {
    return SubLessonEntity(
      id: id,
      title: title,
      introductionTitle: introductionTitle,
      introductionDescription: introductionDescription,
      resources: resources
          .map((resource) => resource.toEntity())
          .toList(growable: false),
    );
  }
}

class ResourceModel {
  final String id;
  final String type;
  final String title;
  final String link;

  const ResourceModel({
    required this.id,
    required this.type,
    required this.title,
    required this.link,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      link: json['link'] as String,
    );
  }

  ResourceEntity toEntity() {
    return ResourceEntity(
      id: id,
      type: _mapType(type),
      title: title,
      link: link,
    );
  }

  ResourceType _mapType(String value) {
    switch (value) {
      case 'youtube':
        return ResourceType.youtube;
      case 'book':
        return ResourceType.book;
      default:
        return ResourceType.book;
    }
  }
}
