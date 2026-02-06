import '../domain/roadmap_entity.dart';

class RoadmapModel extends RoadmapEntity {
  RoadmapModel({
    required super.id,
    required super.title,
    required super.level,
    required super.description,
 
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    return RoadmapModel(
      id: json['id'],
      title: json['title'],
      level: json['level'],
      description: json['description'],
    
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'level': level,
        'description': description,
      
      };
}
