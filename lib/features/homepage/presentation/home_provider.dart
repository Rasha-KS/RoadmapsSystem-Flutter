import 'package:flutter/material.dart';
import '../domain/home_entity.dart';
import '../domain/get_home_data_usecase.dart';

enum HomeState { loading, loaded, connectionError }

class HomeProvider extends ChangeNotifier {
  final GetHomeDataUseCase useCase;
  HomeProvider(this.useCase);

  List<HomeCourseEntity> recommended = [];
  List<HomeCourseEntity> myCourses = [];
  HomeState state = HomeState.loading;

  Future<void> loadHome() async {
    state = HomeState.loading;
    notifyListeners();

    try {
      // محاكاة جلب البيانات
      recommended = await useCase.callRecommended();
      myCourses = await useCase.callMyCourses();
      
      state = HomeState.loaded;
    } catch (e) {
      // إذا حدث خطأ في الشبكة (SocketException مثلاً)
      state = HomeState.connectionError;
    }
    notifyListeners();
  }
}
