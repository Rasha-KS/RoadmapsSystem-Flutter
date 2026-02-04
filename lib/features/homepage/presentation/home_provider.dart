import 'package:flutter/material.dart';
import '../domain/home_entity.dart';
import '../domain/get_home_data_usecase.dart';

class HomeProvider extends ChangeNotifier {
  final GetHomeDataUseCase useCase;

  HomeProvider(this.useCase);

  List<HomeCourseEntity> recommended = [];
  List<HomeCourseEntity> myCourses = [];

  bool loading = true;

  Future<void> loadHome() async {
    loading = true;
    notifyListeners();

    recommended = await useCase.callRecommended();
    myCourses = await useCase.callMyCourses();

    loading = false;
    notifyListeners();
  }
}
