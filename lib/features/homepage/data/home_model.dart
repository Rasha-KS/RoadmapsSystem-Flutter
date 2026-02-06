import '../domain/home_entity.dart';

class HomeCourseModel extends HomeCourseEntity {
  HomeCourseModel({
    required super.id,
    required super.title,
    required super.level,
    required super.description,
    super.status
  });

  factory HomeCourseModel.fromJson(Map<String, dynamic> json) {
    return HomeCourseModel(
      id: json['id'],
      title: json['title'],
      level: json['level'],
      description: json['description'],
      status: json['status']
    );
  }
}
