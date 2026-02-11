import 'package:flutter/material.dart';
import '../domain/get_roadmaps_usecase.dart';
import '../domain/roadmap_entity.dart';

class RoadmapsProvider extends ChangeNotifier {
  final GetRoadmapsUseCase useCase;

  RoadmapsProvider(this.useCase);

  List<RoadmapEntity> roadmaps = [];
  bool loading = false;
  String? error;

  Future<void> loadRoadmaps() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      roadmaps = await useCase();
    } catch (e) {
      error = 'حدث خطأ أثناء تحميل المسارات';
    }

    loading = false;
    notifyListeners();
  }
}
